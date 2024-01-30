use aws_config::BehaviorVersion;
use aws_sdk_timestreamquery::operation::query::QueryError;
use aws_sdk_timestreamquery::Client;
use axum::{
    extract::{Json, Path, State},
    http::StatusCode,
    response::Html,
    routing::*,
    Router,
};
use color_eyre::{eyre::eyre, Result};
use serde::{ser::Error, Serialize};
use serde_json::{json, Value};
use std::collections::HashMap;
use std::sync::Arc;

struct AppState {
    clients: HashMap<String, Client>,
}

impl AppState {
    async fn new() -> Self {
        let mut clients = HashMap::new();
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

        Self { clients }
    }
}
#[tokio::main]
async fn main() {
    // build our application with a route
    let state = Arc::new(AppState::new().await);

    let app = Router::new()
        .route("/", get(hello))
        .with_state(Arc::clone(&state))
        .route(
            "/channel/emotes/:channel",
            get(get_all_channel_emotes).with_state(Arc::clone(&state)),
        )
        .route(
            "/channel/:channel/",
            get(channel_total_emote_count).with_state(Arc::clone(&state)),
        )
        .route(
            "/channel/:channel/average/:interval",
            get(channel_average_emote_count_with_interval).with_state(Arc::clone(&state)),
        )
        .route(
            "/channel/:channel/:emote",
            get(channel_individual_emote_count).with_state(Arc::clone(&state)),
        )
        .route(
            "/emote/:id",
            get(total_emote_count).with_state(Arc::clone(&state)),
        )
        .route(
            "/emote/average/:channel/:emote/:interval",
            get(channel_average_individual_emote_count_with_interval)
                .with_state(Arc::clone(&state)),
        )
        .with_state(Arc::clone(&state));

    // run it
    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    println!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

async fn hello() -> Html<&'static str> {
    Html("<h1>Hello, World!</h1>")
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
