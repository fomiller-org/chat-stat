use aws_lambda_events::{dynamodb::EventRecord, event::dynamodb::Event};
use lambda_runtime::{run, service_fn, Error, LambdaEvent};
use serde::{Deserialize, Serialize};
use std::env;
use std::fmt;
use std::str::FromStr;
use twitch_api::eventsub::stream::StreamOfflineV1;
use twitch_api::eventsub::{stream::online::StreamOnlineV1, Transport};
use twitch_api::helix::ClientRequestError;
use twitch_api::helix::HelixRequestPostError;
use twitch_api::twitch_oauth2::AppAccessToken;
use twitch_api::HelixClient;
use twitch_types::EventSubId;

static LAMBDA_URL: &str = "https://6rm4cdx6bizoo6jsdxatsontnm0sgiym.lambda-url.us-east-1.on.aws/";
static TRANSPORT_SECRET: &str = "abcdef12345678";

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
#[serde(rename = "StreamId")]
struct MyModel {
    #[serde(rename = "StreamId")]
    stream_id: String,
    #[serde(rename = "Online")]
    online: Option<bool>,
    #[serde(rename = "SubscriptionIdOffline")]
    event_sub_id_online: Option<EventSubId>,
    #[serde(rename = "SubscriptionIdOffline")]
    event_sub_id_offline: Option<EventSubId>,
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
            EventName::Remove => {
                println!("Opertaion type {}", event_name);
                handle_remove(record).await?
            }
            _ => println!("Event not handled."),
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

    println!("NEW StreamId: {:?}", &new_item.stream_id);
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

    let online_event = StreamOnlineV1::broadcaster_user_id(user.id.to_owned());
    let offline_event = StreamOfflineV1::broadcaster_user_id(user.id.to_owned());

    let transport = Transport::webhook(LAMBDA_URL.to_string(), TRANSPORT_SECRET.to_string());

    let res = helix_client
        .create_eventsub_subscription(online_event, transport.to_owned(), &token)
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

    let res = helix_client
        .create_eventsub_subscription(offline_event, transport.to_owned(), &token)
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

async fn handle_remove(record: &EventRecord) -> Result<(), Error> {
    let old_image = record.change.old_image.clone();
    let old_item: MyModel = serde_dynamo::from_item(old_image)?;
    println!("OLD StreamId: {:?}", &old_item.stream_id);
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

    let event_ids = vec![
        &old_item.event_sub_id_online,
        &old_item.event_sub_id_offline,
    ];
    for event_id in event_ids {
        if let Some(id) = event_id {
            let res = helix_client.delete_eventsub_subscription(id, &token).await;
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
        } else {
            println!("No SubscriptionId");
            return Ok(());
        }
    }

    Ok(())
}
