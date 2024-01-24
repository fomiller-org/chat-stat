use axum::{
    extract::{Json, Path, Query},
    response::Html,
    routing::*,
    Router,
};

#[tokio::main]
async fn main() {
    // build our application with a route
    let app = Router::new()
        .route("/", get(hello_world))
        .route("/:id", get(my_post));

    // run it
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .unwrap();
    println!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

async fn hello_world() -> Html<&'static str> {
    Html("<h1>Hello, World!</h1>")
}

async fn my_post(Path(user_id): Path<String>) -> Html<String> {
    let res = format!("<h1>Hello, user {}!</h1>", user_id);
    Html(res)
}
