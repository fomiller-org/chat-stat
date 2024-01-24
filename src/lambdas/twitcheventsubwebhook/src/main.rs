use aws_config::BehaviorVersion;
use aws_sdk_dynamodb::{operation::update_item::UpdateItemOutput, types::AttributeValue};
use aws_sdk_sfn::operation::start_execution::StartExecutionOutput;
use lambda_http::{run, service_fn, Body, Error, Request, Response};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, env};
use twitch_api::eventsub::{
    stream::{StreamOfflineV1Payload, StreamOnlineV1Payload},
    Event, EventSubSubscription, EventType, Message, Payload,
};
use twitch_api::twitch_oauth2::AppAccessToken;
use twitch_api::HelixClient;
use twitch_types::{DisplayName, Timestamp, UserId};

#[derive(Serialize, Deserialize)]
struct Condition {
    #[serde(rename = "broadcaster_user_id")]
    user_id: UserId,
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

#[derive(Debug, Serialize, Deserialize)]
struct SfnInput {
    deployment: HashMap<String, String>,
}

#[derive(Debug, Clone)]
struct VerificitionStatus {
    created_at: AttributeValue,
    sub_id: AttributeValue,
    sub_id_key: Option<String>,
    sub_status: AttributeValue,
    table: String,
    user_id: AttributeValue,
    user_login: AttributeValue,
    update_expression: String,
}

impl VerificitionStatus {
    fn new(
        created_at: Timestamp,
        event: EventType,
        sub_id: String,
        user_id: String,
        user_login: String,
    ) -> Self {
        Self {
            created_at: AttributeValue::S(created_at.to_string()),
            sub_id: AttributeValue::S(sub_id.to_string()),
            table: "fomiller-chat-stat".to_string(),
            user_id: AttributeValue::S(user_id.to_string()),
            user_login: AttributeValue::S(user_login.to_string().to_lowercase()),
            update_expression:
                "SET BroadcasterId = :bid, #ss = :sid, CreatedAt = :ca, SubscriptionStatus = :ss"
                    .to_string(),
            sub_id_key: match event {
                EventType::StreamOnline => Some("SubscriptionIdOnline".to_string()),
                EventType::StreamOffline => Some("SubscriptionIdOffline".to_string()),
                _ => None,
            },
            sub_status: AttributeValue::S(String::from("SUBSCRIBED")),
        }
    }

    async fn update(self, client: aws_sdk_dynamodb::Client) -> Result<UpdateItemOutput, Error> {
        let res = client
            .update_item()
            .table_name(self.table)
            .key("StreamId", self.user_login)
            .update_expression(self.update_expression)
            .expression_attribute_values(String::from(":bid"), self.user_id)
            .expression_attribute_values(String::from(":sid"), self.sub_id)
            .expression_attribute_values(String::from(":ca"), self.created_at)
            .expression_attribute_values(String::from(":ss"), self.sub_status)
            .expression_attribute_names(
                String::from("#ss"),
                self.sub_id_key
                    .expect("Could not determine SubscriptionId key."),
            )
            .send()
            .await?;
        Ok(res)
    }
}

#[derive(Debug, Clone)]
struct OnlineStatus {
    online_status: AttributeValue,
    online_status_key: String,
    table: String,
    update_expression: String,
    user_login: AttributeValue,
}

impl OnlineStatus {
    fn new(user_login: &DisplayName, status: bool) -> Self {
        Self {
            online_status: AttributeValue::Bool(status),
            online_status_key: "Online".to_string(),
            table: "fomiller-chat-stat".to_string(),
            update_expression: String::from("SET #o = :o"),
            user_login: AttributeValue::S(user_login.to_string().to_lowercase()),
        }
    }
    async fn update(self, client: aws_sdk_dynamodb::Client) -> Result<UpdateItemOutput, Error> {
        let res = client
            .update_item()
            .table_name(self.table)
            .key("StreamId", self.user_login)
            .update_expression(self.update_expression)
            .expression_attribute_values(String::from(":o"), self.online_status)
            .expression_attribute_names(String::from("#o"), self.online_status_key)
            .send()
            .await?;
        Ok(res)
    }
}

#[derive(Debug, Clone)]
struct TaskToken {
    id: String,
    token: Option<String>,
}

impl TaskToken {
    fn new(id: String) -> Self {
        Self { id, token: None }
    }
    async fn get_token(mut self, client: &aws_sdk_dynamodb::Client) -> Result<Self, Error> {
        let res = client
            .get_item()
            .table_name("fomiller-chat-stat")
            .key("StreamId", AttributeValue::S(self.id.to_lowercase()))
            .send()
            .await?;

        let item = res.item.unwrap();
        let token = item["TaskToken"].as_s().expect("No TaskToken found");
        self.token = Some(token.clone());

        Ok(self.clone())
    }
}

struct StepFunctionExectution {
    arn: String,
    input: String,
}

impl StepFunctionExectution {
    fn new(id: &DisplayName) -> Self {
        let mut deployment = HashMap::new();
        let region = env::var("REGION").expect("Missing REGION env var.");
        let account = env::var("ACCOUNT").expect("Missing ACCOUNT env var.");
        let name = "fomiller-chat-stat-logger".to_string();
        let arn = format!(
            "arn:aws:states:{}:{}:stateMachine:{}",
            region, account, name,
        );
        deployment.insert(
            "stream_id".to_string(),
            id.to_owned().to_string().to_lowercase(),
        );
        let input = serde_json::to_string(&SfnInput { deployment }).unwrap();
        Self { arn, input }
    }

    async fn start(self, client: aws_sdk_sfn::Client) -> Result<StartExecutionOutput, Error> {
        let res = client
            .start_execution()
            .state_machine_arn(self.arn.clone())
            .input(self.input)
            .send()
            .await?;

        Ok(res)
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
    let ddb_client = aws_sdk_dynamodb::Client::new(&config);

    let res = StepFunctionExectution::new(&notif.broadcaster_user_name)
        .start(sfn_client)
        .await?;

    let _ = OnlineStatus::new(&notif.broadcaster_user_name, true)
        .update(ddb_client)
        .await;

    println!("Stream Online");
    println!("SFN RESPONSE: {:?}", res);
    println!("Broadcaster ID {:?}", &notif.broadcaster_user_id);
    println!("Broadcaster User Name {:?}", &notif.broadcaster_user_name);
    Ok(())
}

async fn handle_offline(notif: StreamOfflineV1Payload) -> Result<(), Error> {
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region("us-east-1")
        .load()
        .await;
    let sfn_client = aws_sdk_sfn::Client::new(&config);
    let ddb_client = aws_sdk_dynamodb::Client::new(&config);

    let token = TaskToken::new(notif.broadcaster_user_name.to_string())
        .get_token(&ddb_client)
        .await
        .unwrap()
        .token
        .unwrap();

    let sfn_res = sfn_client
        .send_task_success()
        .task_token(token)
        .output("{}")
        .send()
        .await;

    let _ = OnlineStatus::new(&notif.broadcaster_user_name, false)
        .update(ddb_client)
        .await;

    println!("Stream Offline");
    println!("SFN RESPONSE: {:?}", sfn_res);
    println!("Broadcaster ID {:?}", notif.broadcaster_user_id);
    println!("Broadcaster User Name {:?}", notif.broadcaster_user_name);
    Ok(())
}

async fn handle_verification(sub: EventSubSubscription) -> Result<(), Error> {
    let condition: Condition = serde_json::from_value(sub.clone().condition).unwrap();

    let config = aws_config::defaults(BehaviorVersion::latest())
        .region("us-east-1")
        .load()
        .await;
    let ddb_client = aws_sdk_dynamodb::Client::new(&config);

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
        .get_user_from_id(&condition.user_id, &token)
        .await?
        .unwrap();

    println!("User: {:?}", user);

    let res = VerificitionStatus::new(
        sub.created_at,
        sub.type_,
        sub.id.to_string(),
        user.id.to_string(),
        user.login.to_string(),
    )
    .update(ddb_client)
    .await?;

    println!("Item is updated. New Item: {:?}", res.attributes);

    Ok(())
}
#[cfg(test)]
mod tests {
    use aws_sdk_dynamodb::types::AttributeValue;
    use lambda_http::Error;
    use twitch_api::eventsub::EventType;
    use twitch_types::Timestamp;

    use crate::TwitchCreds;
    use crate::VerificitionStatus;

    #[test]
    fn twitch_creds_new() {
        std::env::set_var("TWITCH_CLIENT_ID", "id123");
        std::env::set_var("TWITCH_CLIENT_SECRET", "secret123");
        let creds = TwitchCreds::new();
        assert_eq!(creds.client_id, "id123");
        assert_eq!(creds.client_secret, "secret123")
    }

    #[test]
    fn verification_status_new() -> Result<(), Error> {
        let timestamp = Timestamp::now();
        let v = VerificitionStatus::new(
            timestamp.clone(),
            EventType::StreamOnline,
            "abcedf".to_string(),
            "123456".to_string(),
            "NewDay".to_string(),
        );
        assert_eq!(v.table, "fomiller-chat-stat".to_string());
        assert_eq!(v.created_at, AttributeValue::S(timestamp.to_string()));
        assert_eq!(v.sub_id, AttributeValue::S("abcedf".to_string()));
        assert_eq!(v.user_id, AttributeValue::S("123456".to_string()));
        assert_eq!(v.user_login, AttributeValue::S("newday".to_string()));
        assert_eq!(v.sub_id_key, Some("SubscriptionIdOnline".to_string()));
        assert_eq!(v.sub_status, AttributeValue::S("SUBSCRIBED".to_string()));
        assert_eq!(
            v.update_expression,
            "SET BroadcasterId = :bid, #ss = :sid, CreatedAt = :ca, SubscriptionStatus = :ss"
                .to_string()
        );

        let v = VerificitionStatus::new(
            timestamp.clone(),
            EventType::StreamOffline,
            "abcedf".to_string(),
            "123456".to_string(),
            "NewDay".to_string(),
        );
        assert_eq!(v.sub_id_key, Some("SubscriptionIdOffline".to_string()));

        let v = VerificitionStatus::new(
            timestamp.clone(),
            EventType::ChannelSubscribe,
            "abcedf".to_string(),
            "123456".to_string(),
            "NewDay".to_string(),
        );
        assert_eq!(v.sub_id_key, None);
        Ok(())
    }
}
