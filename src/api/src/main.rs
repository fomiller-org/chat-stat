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
use std::error::Error;
// use color_eyre::{eyre::eyre, Result};
use serde::Serialize;
use serde_json::{json, Value};
use std::collections::HashMap;
use std::sync::Arc;

#[tokio::main]
async fn main() {
    // build our application with a route
    let state = Arc::new(AppState::new().await);

    let app = Router::new()
        .route("/query/:id", get(query).with_state(Arc::clone(&state)))
        .route("/", get(hello))
        .with_state(Arc::clone(&state))
        .route("/hello", get(hello_world))
        .with_state(Arc::clone(&state));

    // run it
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .unwrap();
    println!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

pub async fn hello() {
    println!("<h1>Hello, World!</h1>")
}

async fn hello_world() -> Html<&'static str> {
    Html("<h1>Hello, World!</h1>")
}

async fn query(
    Path(user_id): Path<String>,
    State(state): State<Arc<AppState>>,
) -> Result<Json<Value>, StatusCode> {
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
            Ok(Json(json!({"query": x})))
        }
        Err(e) => {
            eprintln!("{:?}", e.as_service_error());
            Err(StatusCode::NOT_FOUND)
        }
    }
}

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
