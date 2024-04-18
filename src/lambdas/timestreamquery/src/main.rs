use lambda_runtime::{run, service_fn, tracing, Error, LambdaEvent};
use serde::{Deserialize, Serialize};

use std::str::FromStr;
use std::string::ToString;
use strum_macros::EnumString;

#[derive(Deserialize, Debug)]
struct Request {
    channel: Option<String>,
    query_schedule: String,
    query_type: String,
}

#[derive(Serialize)]
struct Response {
    req_id: String,
    msg: String,
}

#[derive(strum_macros::Display, Deserialize, Debug, EnumString)]
#[strum(serialize_all = "snake_case")]
enum QueryType {
    TopEmote,
}

#[derive(strum_macros::Display, Deserialize, Debug, EnumString)]
#[strum(serialize_all = "snake_case")]
enum QuerySchedule {
    Daily,
    Weekly,
    Monthly,
}

async fn function_handler(event: LambdaEvent<Request>) -> Result<Response, Error> {
    // Extract some useful info from the request
    println!("{:?}", event.payload);
    let channel = event.payload.channel.unwrap_or("".to_string());
    let query_type = QueryType::from_str(&event.payload.query_type)?;
    let query_schedule = QuerySchedule::from_str(&event.payload.query_schedule)?;

    // Prepare the response
    let resp = Response {
        req_id: event.context.request_id,
        msg: format!(
            "query schedule is {}, query type is {}, channel is {}",
            query_schedule, query_type, channel
        ),
    };

    Ok(resp)
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    run(service_fn(function_handler)).await
}
