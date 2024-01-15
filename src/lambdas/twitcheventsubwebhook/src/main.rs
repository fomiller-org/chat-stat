use aws_config::BehaviorVersion;
use aws_sdk_dynamodb::client::Client;
use aws_sdk_dynamodb::types::AttributeValue;
use lambda_http::{run, service_fn, Body, Error, Request, Response};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, env};
use twitch_api::eventsub::{
    stream::{StreamOfflineV1Payload, StreamOnlineV1Payload},
    Event, EventSubSubscription, Message, Payload,
};
use twitch_api::twitch_oauth2::AppAccessToken;
use twitch_api::HelixClient;
use twitch_types::UserId;

#[derive(Serialize, Deserialize)]
struct Condition {
    broadcaster_user_id: UserId,
    #[serde(skip_deserializing)]
    created_at: String,
}

struct TwitchCreds {
    client_id: String,
    client_secret: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct SfnInput {
    deployment: HashMap<String, String>,
}

impl TwitchCreds {
    fn new() -> TwitchCreds {
        let twitch_client_secret: String = env::var("TWITCH_CLIENT_SECRET").unwrap();
        let twitch_client_id: String = env::var("TWITCH_CLIENT_ID").unwrap();
        TwitchCreds {
            client_id: twitch_client_id,
            client_secret: twitch_client_secret,
        }
    }
}

async fn function_handler(request: Request) -> Result<Response<Body>, Error> {
    let headers = request.headers();
    let body = request.body();
    println!("REQUEST: {:?}\n", request);
    println!("HEADERS: {:?}\n", headers);
    println!("BODY: {:?}\n", body);

    let event = Event::parse_http(&request)?;

    if let Some(verification) = event.get_verification_request() {
        println!("Subscription Verified");

        let subscription = event.subscription()?;
        let resp = Response::builder()
            .status(200)
            .header("content-type", "text/plain")
            .body(verification.challenge.clone().into())
            .map_err(Box::new)?;

        handle_verification(subscription).await?;

        return Ok(resp);
    }

    if event.is_revocation() {
        println!("Subscription Revoked");
        let resp = Response::builder()
            .status(200)
            .header("content-type", "text/plain")
            .body("".into())
            .map_err(Box::new)?;
        return Ok(resp);
    }

    match event {
        Event::StreamOnlineV1(Payload {
            message: Message::Notification(notif),
            ..
        }) => handle_online(notif).await?,
        Event::StreamOfflineV1(Payload {
            message: Message::Notification(notif),
            ..
        }) => handle_offline(notif).await?,
        _ => println!("EventType not supported"),
    }

    // Return something that implements IntoResponse.
    let resp = Response::builder()
        .status(200)
        .header("content-type", "text/plain")
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

async fn handle_online(notif: StreamOnlineV1Payload) -> Result<(), Error> {
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region("us-east-1")
        .load()
        .await;

    let sfn_client = aws_sdk_sfn::Client::new(&config);
    let region = env::var("AWS_REGION").expect("Missing AWS_REGION env var.");
    let account = env::var("AWS_ACCOUNT").expect("Missing AWS_ACCOUNT env var.");
    let sfn_name = "fomiller-chat-stat-logger";

    let arn = format!(
        "arn:aws:states:{}:{}:stateMachine:{}",
        region, account, sfn_name,
    );
    let mut deployment = HashMap::new();

    deployment.insert(
        "stream_id".to_string(),
        notif.broadcaster_user_name.to_string(),
    );

    let sfn_input = serde_json::to_string(&SfnInput { deployment }).unwrap();

    let sfn_res = sfn_client
        .start_execution()
        .state_machine_arn(&arn)
        .input(sfn_input)
        .send()
        .await?;

    println!("Stream Online");
    println!("SFN RESPONSE: {:?}", sfn_res);
    println!("Broadcaster ID {:?}", notif.broadcaster_user_id);
    println!("Broadcaster User Name {:?}", notif.broadcaster_user_name);
    Ok(())
}
async fn handle_offline(notif: StreamOfflineV1Payload) -> Result<(), Error> {
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region("us-east-1")
        .load()
        .await;
    let sfn_client = aws_sdk_sfn::Client::new(&config);
    let ddb_client = Client::new(&config);

    let stream_id = AttributeValue::S(notif.broadcaster_user_name.to_string());
    let item = ddb_client
        .get_item()
        .key("StreamId", stream_id)
        .send()
        .await
        .unwrap()
        .item
        .unwrap();

    let token = item["TaskToken"].as_s().expect("No TaskToken found");

    let sfn_res = sfn_client
        .send_task_success()
        .task_token(token)
        .output("{}")
        .send()
        .await;

    println!("Stream Offline");
    println!("SFN RESPONSE: {:?}", sfn_res);
    println!("Broadcaster ID {:?}", notif.broadcaster_user_id);
    println!("Broadcaster User Name {:?}", notif.broadcaster_user_name);
    Ok(())
}

async fn handle_verification(sub: EventSubSubscription) -> Result<(), Error> {
    let mut condition: Condition = serde_json::from_value(sub.condition).unwrap();
    condition.created_at = sub.created_at.to_string();

    let config = aws_config::defaults(BehaviorVersion::latest())
        .region("us-east-1")
        .load()
        .await;

    let ddb_client = Client::new(&config);

    let creds = TwitchCreds::new();

    let helix_client: HelixClient<reqwest::Client> = HelixClient::new();

    let token = AppAccessToken::get_app_access_token(
        &helix_client,
        creds.client_id.into(),
        creds.client_secret.into(),
        vec![],
    )
    .await?;

    let user = helix_client
        .get_user_from_id(&condition.broadcaster_user_id, &token)
        .await?
        .unwrap();
    println!("User: {:?}", user);

    let table_name = String::from("fomiller-chat-stat");
    let user_id = AttributeValue::S(String::from(user.login));
    let broadcaster_user_id = AttributeValue::S(String::from(condition.broadcaster_user_id));
    let sub_id = AttributeValue::S(String::from(sub.id));
    let created_at = AttributeValue::S(String::from(condition.created_at));
    let sub_status = AttributeValue::S(String::from("SUBSCRIBED"));
    let update_expression =
        String::from("SET BroadcasterId = :bid, SubscriptionId = :sid, CreatedAt = :ca, SubscriptionStatus = :ss");

    let request = ddb_client
        .update_item()
        .table_name(table_name)
        .key("StreamId", user_id)
        .update_expression(update_expression)
        .expression_attribute_values(String::from(":bid"), broadcaster_user_id)
        .expression_attribute_values(String::from(":sid"), sub_id)
        .expression_attribute_values(String::from(":ca"), created_at)
        .expression_attribute_values(String::from(":ss"), sub_status);
    let resp = request.send().await?;
    println!("Item is updated. New Item: {:?}", resp.attributes);

    Ok(())
}
