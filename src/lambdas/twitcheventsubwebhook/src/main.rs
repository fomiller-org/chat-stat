use lambda_http::{run, service_fn, Body, Error, Request, Response};
use twitch_api::eventsub::{
    stream::{StreamOfflineV1Payload, StreamOnlineV1Payload},
    Event, Message, Payload,
};

async fn function_handler(request: Request) -> Result<Response<Body>, Error> {
    let headers = request.headers();
    let body = request.body();
    println!("HEADERS: {:?}", headers);
    println!("BODY: {:?}", body);

    let event = Event::parse_http(&request)?;

    if let Some(verification) = event.get_verification_request() {
        println!("Subscription Verified");
        let resp = Response::builder()
            .status(200)
            .header("content-type", "text/html")
            .body(verification.challenge.clone().into())
            .map_err(Box::new)?;
        return Ok(resp);
    }

    if event.is_revocation() {
        println!("Subscription Revoked");
        let resp = Response::builder()
            .status(200)
            .header("content-type", "text/html")
            .body("".into())
            .map_err(Box::new)?;
        return Ok(resp);
    }

    match event {
        Event::StreamOnlineV1(Payload {
            message: Message::Notification(notif),
            ..
        }) => handle_online(notif),
        Event::StreamOfflineV1(Payload {
            message: Message::Notification(notif),
            ..
        }) => handle_offline(notif),
        _ => println!("event not supported"),
    }

    // Return something that implements IntoResponse.
    let resp = Response::builder()
        .status(200)
        .header("content-type", "text/html")
        .body(format!("Twitch EventSub Webhook").into())
        .map_err(Box::new)?;
    Ok(resp)
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        // disable printing the name of the module in every log line.
        .with_target(false)
        // disabling time is handy because CloudWatch will add the ingestion time.
        .without_time()
        .init();

    run(service_fn(function_handler)).await
}

fn handle_online(notif: StreamOnlineV1Payload) {
    println!("Stream Online");
    println!("Broadcaster ID {:?}", notif.broadcaster_user_id);
    println!("Broadcaster User Name {:?}", notif.broadcaster_user_name)
}
fn handle_offline(notif: StreamOfflineV1Payload) {
    println!("Stream Offline");
    println!("Broadcaster ID {:?}", notif.broadcaster_user_id);
    println!("Broadcaster User Name {:?}", notif.broadcaster_user_name)
}
