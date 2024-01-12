use aws_config::BehaviorVersion;
use aws_sdk_dynamodb::client::Client;
use aws_sdk_dynamodb::types::{AttributeValue, ReturnValue};
use lambda_runtime::{run, service_fn, Error, LambdaEvent};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::env;
use std::fmt;
use std::str::FromStr;
use tracing::span::Attributes;
use twitch_api::helix::HelixClient;
use twitch_api::twitch_oauth2::AppAccessToken;

#[derive(Debug, Deserialize, Serialize)]
struct Request {
    #[serde(rename = "eventName")]
    event_name: String,
    key: String,
}

#[derive(Debug, PartialEq)]
enum EventName {
    Insert,
    Modify,
    Remove,
}

struct TwitchCreds {
    client_id: String,
    client_secret: String,
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
impl FromStr for EventName {
    type Err = ();
    fn from_str(input: &str) -> Result<EventName, Self::Err> {
        match input {
            "INSERT" => Ok(EventName::Insert),
            "MODIFY" => Ok(EventName::Modify),
            "REMOVE" => Ok(EventName::Remove),
            _ => Err(()),
        }
    }
}
impl fmt::Display for EventName {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            EventName::Insert => write!(f, "INSERT"),
            EventName::Modify => write!(f, "MODIFY"),
            EventName::Remove => write!(f, "REMOVE"),
        }
    }
}
async fn function_handler(event: LambdaEvent<Request>) -> Result<(), Error> {
    println!("EVENT: {:?}", event.payload);
    // Prepare the response
    let event_name = EventName::from_str(event.payload.event_name.as_str()).unwrap();
    let key = &event.payload.key;

    println!("EventName {}, Key {}", &event_name, &key);
    match event_name {
        EventName::Insert => handle_insert(&key).await?,
        EventName::Remove => handle_remove(&key).await?,
        _ => println!("Event Type not supported : {}", event_name),
    }
    Ok(())
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

async fn handle_insert(key: &String) -> Result<(), Error> {
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region("us-east-1")
        .load()
        .await;

    let dynamodb_client = Client::new(&config);
    let creds = TwitchCreds::new();

    let helix_client: HelixClient<reqwest::Client> = HelixClient::new();

    let token = AppAccessToken::get_app_access_token(
        &helix_client,
        creds.client_id.into(),
        creds.client_secret.into(),
        vec![],
    )
    .await?;

    let user = helix_client.get_user_from_login(key, &token).await?;
    if let Some(user) = user {
        let table_name = String::from("fomiller-chat-stat");
        let item = HashMap::from([
            (
                "StreamId".to_string(),
                AttributeValue::S(String::from(user.login)),
            ),
            (
                "BroadcasterId".to_string(),
                AttributeValue::S(String::from(user.id)),
            ),
            (
                "SubscriptionStatus".to_string(),
                AttributeValue::S(String::from("PENDING")),
            ),
            ("Online".to_string(), AttributeValue::Bool(false)),
        ]);

        dynamodb_client
            .put_item()
            .table_name(table_name)
            .set_item(Some(item))
            .send()
            .await?;

        println!("Item succesfully created");
    } else {
        println!("Could Not find User: {}", key)
    }

    Ok(())
}
async fn handle_remove(key: &String) -> Result<(), Error> {
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region("us-east-1")
        .load()
        .await;

    let dynamodb_client = Client::new(&config);

    let table_name = String::from("fomiller-chat-stat");
    let stream_id = AttributeValue::S(String::from(key));

    let res = dynamodb_client
        .delete_item()
        .table_name(table_name)
        .key("StreamId", stream_id)
        .return_values(ReturnValue::AllOld)
        .send()
        .await?;

    if let Some(attrs) = res.attributes {
        println!("Delete Successful. Item deleted: {:?}", attrs);
    } else {
        println!("No record Found.")
    }

    Ok(())
}
