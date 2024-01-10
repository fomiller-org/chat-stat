use aws_lambda_events::{dynamodb::EventRecord, event::dynamodb::Event};
use lambda_runtime::{run, service_fn, Error, LambdaEvent};
use serde::{Deserialize, Serialize};
use std::env;
use std::fmt;
use std::str::FromStr;
use twitch_api::eventsub::{stream::online::StreamOnlineV1, Transport};
use twitch_api::helix::ClientRequestError;
use twitch_api::helix::HelixRequestPostError;
use twitch_api::twitch_oauth2::AppAccessToken;
use twitch_api::HelixClient;
use twitch_types::EventSubId;

static LAMBDA_URL: &str = "https://6rm4cdx6bizoo6jsdxatsontnm0sgiym.lambda-url.us-east-1.on.aws/";
static TRANSPORT_SECRET: &str = "abc1234";

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

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename = "StreamID")]
struct MyModel {
    #[serde(rename = "StreamID")]
    stream_id: String,
    #[serde(rename = "Online")]
    online: Option<bool>,
    #[serde(rename = "SubscriptionId")]
    event_sub_id: Option<EventSubId>,
}

impl MyModel {
    fn get_online(self) -> bool {
        self.online.unwrap_or_default()
    }
}

async fn function_handler(event: LambdaEvent<Event>) -> Result<(), Error> {
    println!("Event: {:?}\n", event);
    for record in event.payload.records.iter() {
        let event_name = EventName::from_str(record.event_name.as_str()).unwrap();
        match event_name {
            EventName::Insert => {
                println!("Opertaion type {}", event_name);
                handle_insert(record).await?
            }
            EventName::Modify => {
                println!("Opertaion type {}", event_name);
                handle_modify(record).unwrap()
            }
            EventName::Remove => {
                println!("Opertaion type {}", event_name);
                handle_remove(record).await?
            }
        };
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

async fn handle_insert(record: &EventRecord) -> Result<(), Error> {
    let new_image = record.change.new_image.clone();
    let new_item: MyModel = serde_dynamo::from_item(new_image)?;

    println!("NEW StreamID: {:?}", &new_item.stream_id);
    println!("NEW Online Status: {:?}", &new_item.clone().get_online());

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
        .get_user_from_login(&new_item.stream_id, &token)
        .await?
        .unwrap();

    let event = StreamOnlineV1::broadcaster_user_id(user.id);

    let transport = Transport::webhook(LAMBDA_URL.to_string(), TRANSPORT_SECRET.to_string());

    let res = helix_client
        .create_eventsub_subscription(event, transport, &token)
        .await;

    match res {
        Ok(event) => {
            println!("Subscription created Successfully");
            println!("Create Event Sub Res: {:?}", event);
        }
        Err(error) => match error {
            ClientRequestError::HelixRequestPostError(HelixRequestPostError::Error {
                error,
                status,
                message,
                ..
            }) => {
                println!("There was an Error: {}", error);
                println!("Status: {}", status);
                println!("Message: {}", message);
            }
            _ => return Err(Box::new(error)),
        },
    }

    Ok(())
}

fn handle_modify(record: &EventRecord) -> Result<(), Error> {
    let new_image = record.change.new_image.clone();
    let old_image = record.change.old_image.clone();
    let new_item: MyModel = serde_dynamo::from_item(new_image)?;
    let old_item: MyModel = serde_dynamo::from_item(old_image)?;

    println!("NEW StreamID: {:?}", new_item.stream_id);
    println!("NEW Online Status: {:?}", new_item.get_online());

    println!("OLD StreamID: {:?}", old_item.stream_id);
    println!("OLD Online Status: {:?}", old_item.get_online());
    Ok(())
}

async fn handle_remove(record: &EventRecord) -> Result<(), Error> {
    let old_image = record.change.old_image.clone();
    let old_item: MyModel = serde_dynamo::from_item(old_image)?;
    println!("OLD StreamID: {:?}", &old_item.stream_id);
    println!("OLD Online Status: {:?}", &old_item.clone().get_online());

    let creds = TwitchCreds::new();

    let helix_client: HelixClient<reqwest::Client> = HelixClient::new();

    let token = AppAccessToken::get_app_access_token(
        &helix_client,
        creds.client_id.into(),
        creds.client_secret.into(),
        vec![],
    )
    .await?;

    let res = helix_client
        .delete_eventsub_subscription(&old_item.event_sub_id.unwrap(), &token)
        .await;

    match res {
        Ok(event) => {
            println!("Delete Event Sub Response: {:?}", event);
        }
        Err(error) => match error {
            ClientRequestError::HelixRequestPostError(HelixRequestPostError::Error {
                error,
                status,
                message,
                ..
            }) => {
                println!("There was an Error: {}", error);
                println!("Status: {}", status);
                println!("Message: {}", message);
            }
            _ => return Err(Box::new(error)),
        },
    }

    Ok(())
}
