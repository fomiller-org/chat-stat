use lambda_http::{run, service_fn, Body, Error, Request, Response};
use twitch_api::eventsub::{
    stream::{StreamOfflineV1Payload, StreamOnlineV1Payload},
    Event, Message, Payload,
};

async fn function_handler(request: Request) -> Result<Response<Body>, Error> {
    let event = Event::parse_http(&request)?;

    match event {
        Event::StreamOnlineV1(Payload {
            message: Message::Notification(notif),
            ..
        }) => handle_online(notif),
        Event::StreamOfflineV1(Payload {
            message: Message::Notification(notif),
            ..
        }) => handle_online(notif),
        _ => println!("event not supported"),
    }

    let message = format!("Twitch EventSub Webhook");

    // Return something that implements IntoResponse.
    let resp = Response::builder()
        .status(200)
        .header("content-type", "text/html")
        .body(message.into())
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

fn handle_online(notif: Payload<StreamOnlineV1Payload>) {
    println!("Stream Online");
    println!("Broadcaster ID {:?}", notif.broadcaster_user_id);
    println!("Broadcaster User Name {:?}", notif.broadcaster_user_name)
}
fn handle_offline(notif: Payload<StreamOfflineV1Payload>) {
    println!("Stream Offline");
    println!("Broadcaster ID {:?}", notif.broadcaster_user_id);
    println!("Broadcaster User Name {:?}", notif.broadcaster_user_name)
}
