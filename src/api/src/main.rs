use askama::Template;
use aws_config::BehaviorVersion;
use aws_sdk_timestreamquery::Client;
use axum::http::HeaderMap;
use axum::{
    extract::{Form, Json, Path, State},
    http::StatusCode,
    response::{Html, IntoResponse, Response},
    routing::*,
    Router,
};
use color_eyre::Result;
use rand::Rng;
use serde::Deserialize;
use serde_json::{json, Value};
use std::sync::Arc;
use std::{collections::HashMap, sync::Mutex};
use tower_http::services::ServeDir;
use tracing::info;
use tracing_subscriber::{fmt, prelude::*, EnvFilter};

#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(fmt::layer())
        .with(EnvFilter::from_default_env())
        .init();

    info!("initializing state...");
    // build our application with a route
    let state = Arc::new(AppState::new().await);
    let assets_path = std::env::current_dir().unwrap();

    info!("initializing routers...");
    let api_router = Router::new()
        .route("/hello", get(hello_from_the_server))
        .route("/todos", post(add_todo))
        .route("/data", get(update_chart))
        .route("/json", get(get_json))
        .route("/channel/:channel/", get(channel_total_emote_count))
        .route(
            "/channel/:channel/average/:interval",
            get(channel_average_emote_count_with_interval),
        )
        .route(
            "/channel/:channel/:emote",
            get(channel_individual_emote_count),
        )
        .route("/channel/emotes/:channel", get(get_all_channel_emotes))
        .route("/emote/:id", get(total_emote_count))
        .route(
            "/emote/average/:channel/:emote/:interval",
            get(channel_average_individual_emote_count_with_interval),
        )
        .with_state(Arc::clone(&state));

    let app = Router::new()
        .nest("/api", api_router)
        .route("/", get(hello))
        .route("/todos", get(another_page))
        .route("/dashboard", get(dashboard_page))
        .with_state(Arc::clone(&state))
        .nest_service(
            "/assets",
            ServeDir::new(format!("{}/assets", assets_path.to_str().unwrap())),
        )
        .with_state(Arc::clone(&state));

    // run it
    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    println!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

struct AppState {
    clients: HashMap<String, Client>,
    todos: Mutex<Vec<String>>,
}

impl AppState {
    async fn new() -> Self {
        let mut clients = HashMap::new();
        let todos = Mutex::new(vec![]);
        let config = aws_config::defaults(BehaviorVersion::latest())
            .region("us-east-1")
            .load()
            .await;

        let query_client = aws_sdk_timestreamquery::Client::new(&config)
            .with_endpoint_discovery_enabled()
            .await;

        match query_client {
            Ok(client) => {
                clients.insert("query".to_string(), client.0);
            }
            Err(e) => {
                eprintln!("Error establishing Timestream Query Client {:?}", e);
            }
        }

        Self { clients, todos }
    }
}

// returns the total emotes in the database table
async fn total_emote_count(State(state): State<Arc<AppState>>) -> Result<Json<Value>, StatusCode> {
    let query = r#"select count(*) from fomiller."chat-stat""#;
    let res = state.clients["query"]
        .query()
        .query_string(query)
        .send()
        .await;

    match res {
        Ok(r) => {
            let x = r
                .rows()
                .first()
                .unwrap()
                .data()
                .first()
                .unwrap()
                .scalar_value()
                .unwrap();
            println!("{:?}", x);

            Ok(Json(json!({"total emote count": x})))
        }
        Err(e) => {
            eprintln!("{:?}", e.as_service_error());
            Err(StatusCode::NOT_FOUND)
        }
    }
}

// returns total amount of emotes in a channel. Includes duplicates
async fn channel_total_emote_count(
    Path(channel): Path<String>,
    State(state): State<Arc<AppState>>,
) -> Result<Json<Value>, StatusCode> {
    let query = format!(
        r#"
        select count(*) as total_emotes
        from fomiller."chat-stat"
        where channel='{}'
        "#,
        channel
    );
    let res = state.clients["query"]
        .query()
        .query_string(query)
        .send()
        .await;

    match res {
        Ok(r) => {
            let x = r
                .rows()
                .first()
                .unwrap()
                .data()
                .first()
                .unwrap()
                .scalar_value()
                .unwrap();
            println!("{:?}", x);
            Ok(Json(json!({format!("{} total emote count", channel): x})))
        }
        Err(e) => {
            eprintln!("{:?}", e.as_service_error());
            Err(StatusCode::NOT_FOUND)
        }
    }
}

// returns the total count of an emote used in channel
async fn channel_individual_emote_count(
    Path((channel, emote)): Path<(String, String)>,
    State(state): State<Arc<AppState>>,
) -> Result<Json<Value>, StatusCode> {
    let query = format!(
        r#"
        select count(*) as total_emotes
        from fomiller."chat-stat"
        where channel='{}' and emote='{}'
        "#,
        channel, emote
    );
    let res = state.clients["query"]
        .query()
        .query_string(query)
        .send()
        .await;

    match res {
        Ok(r) => {
            let x = r
                .rows()
                .first()
                .unwrap()
                .data()
                .first()
                .unwrap()
                .scalar_value()
                .unwrap();
            println!("{:?}", x);
            Ok(Json(json!({"count": x})))
        }
        Err(e) => {
            eprintln!("{:?}", e.as_service_error());
            Err(StatusCode::NOT_FOUND)
        }
    }
}

// returns the number of emotes used x interval
async fn channel_average_emote_count_with_interval(
    Path((channel, interval)): Path<(String, String)>,
    State(state): State<Arc<AppState>>,
) -> Result<Json<Value>, StatusCode> {
    let query = format!(
        r#"
        SELECT BIN(time,{}s) AS binned_timestamp, count(*) AS emote_count
        FROM "fomiller"."chat-stat"
        WHERE measure_name = 'count'
            AND channel = '{}'
            AND time > ago(2h)
        GROUP BY channel, BIN(time, {}s)
        ORDER BY binned_timestamp ASC
        "#,
        interval, channel, interval
    );
    let res = state.clients["query"]
        .query()
        .query_string(query)
        .send()
        .await;

    match res {
        Ok(r) => {
            let x = r.rows();
            let data = x
                .into_iter()
                .map(|r| {
                    r.data()
                        .into_iter()
                        .map(|d| d.scalar_value().unwrap().to_string())
                        .collect::<Vec<String>>()
                })
                .collect::<Vec<Vec<String>>>();
            Ok(Json(json!({
                "total rows": x.len(),
                "rows": data
            })))
        }
        Err(e) => {
            eprintln!("{:?}", e.as_service_error());
            Err(StatusCode::NOT_FOUND)
        }
    }
}

// returns the number of times an emote appeared in x interval
async fn channel_average_individual_emote_count_with_interval(
    Path((channel, emote, interval)): Path<(String, String, String)>,
    State(state): State<Arc<AppState>>,
) -> Result<Json<Value>, StatusCode> {
    let query = format!(
        r#"
        SELECT BIN(time,{}s) AS binned_timestamp, count(emote) AS emote_count
        FROM "fomiller"."chat-stat"
        WHERE measure_name = 'count'
            AND emote = '{}'
            AND channel = '{}'
            AND time > ago(2h)
        GROUP BY channel, BIN(time, {}s)
        ORDER BY binned_timestamp ASC
        "#,
        interval, emote, channel, interval
    );
    let res = state.clients["query"]
        .query()
        .query_string(query)
        .send()
        .await;

    match res {
        Ok(r) => {
            let x = r.rows();
            let data = x
                .into_iter()
                .map(|r| {
                    r.data()
                        .into_iter()
                        .map(|d| d.scalar_value().unwrap().to_string())
                        .collect::<Vec<String>>()
                })
                .collect::<Vec<Vec<String>>>();
            Ok(Json(json!({
                "total rows": x.len(),
                "rows": data
            })))
        }
        Err(e) => {
            eprintln!("{:?}", e.as_service_error());
            Err(StatusCode::NOT_FOUND)
        }
    }
}

//returns all emotes that have been used in channel
async fn get_all_channel_emotes(
    Path(channel): Path<String>,
    State(state): State<Arc<AppState>>,
) -> Result<Json<Value>, StatusCode> {
    let query = format!(
        r#"
        SELECT
           emote
        FROM "fomiller"."chat-stat"
        WHERE channel='{}'
        GROUP BY emote
        "#,
        channel
    );
    let res = state.clients["query"]
        .query()
        .query_string(query)
        .send()
        .await;

    match res {
        Ok(r) => {
            let x = r.rows();
            let data = x
                .into_iter()
                .map(|r| {
                    r.data()
                        .into_iter()
                        .filter_map(|d| d.scalar_value())
                        .map(|d| d.to_string())
                        .collect::<Vec<String>>()
                })
                .flatten()
                .collect::<Vec<String>>();
            Ok(Json(json!({
                "total emotes": x.len(),
                "emotes": data
            })))
        }
        Err(e) => {
            eprintln!("{:?}", e.as_service_error());
            Err(StatusCode::NOT_FOUND)
        }
    }
}

async fn hello() -> impl IntoResponse {
    let template = HelloTemplate {};
    HtmlTemplate(template)
}

#[derive(Template)]
#[template(path = "pages/hello.html")]
struct HelloTemplate;

struct HtmlTemplate<T>(T);

/// Allows us to convert Askama HTML templates into valid HTML for axum to serve in the response.
impl<T> IntoResponse for HtmlTemplate<T>
where
    T: Template,
{
    fn into_response(self) -> Response {
        // Attempt to render the template with askama
        match self.0.render() {
            // If we're able to successfully parse and aggregate the template, serve it
            Ok(html) => Html(html).into_response(),
            // If we're not, return an error or some bit of fallback HTML
            Err(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Failed to render template. Error: {}", err),
            )
                .into_response(),
        }
    }
}

async fn another_page() -> impl IntoResponse {
    let template = TodosPageTemplate {};
    HtmlTemplate(template)
}

#[derive(Template)]
#[template(path = "pages/todos.html")]
struct TodosPageTemplate;

async fn hello_from_the_server() -> &'static str {
    "Hello!"
}

#[derive(Template)]
#[template(path = "components/todo-list.html")]
struct TodoList {
    todos: Vec<String>,
}

#[derive(Deserialize)]
struct TodoRequest {
    todo: String,
}

async fn add_todo(
    State(state): State<Arc<AppState>>,
    Form(todo): Form<TodoRequest>,
) -> impl IntoResponse {
    let mut lock = state.todos.lock().unwrap();
    lock.push(todo.todo);
    let template = TodoList {
        todos: lock.clone(),
    };
    HtmlTemplate(template)
}

#[derive(Template)]
#[template(path = "pages/dashboard.html")]
struct DashboardPageTemplate;

async fn dashboard_page() -> impl IntoResponse {
    let template = DashboardPageTemplate {};
    HtmlTemplate(template)
}

#[derive(Template)]
#[template(path = "components/update-chart.html")]
struct UpdateChartTemplate {
    data: Value,
}

async fn update_chart() -> impl IntoResponse {
    let mut data: Vec<u32> = vec![];
    for _ in 0..10 {
        let num = rand::thread_rng().gen_range(1000..9999);
        data.push(num)
    }
    let x = json!(data);
    let template = UpdateChartTemplate { data: x };
    HtmlTemplate(template)
}

async fn get_json() -> impl IntoResponse {
    let mut headers = HeaderMap::new();
    let mut data: Vec<u32> = vec![];
    for _ in 0..5 {
        let num = rand::thread_rng().gen_range(1000..9999);
        data.push(num)
    }
    let header_data = serde_json::to_string(&json!({ "myEvent": {"data": data}})).unwrap();
    headers.insert("HX-Trigger", header_data.parse().unwrap());
    headers
}
