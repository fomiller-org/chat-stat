// use std::fmt::{Display, Result};
use std::fmt;
use std::str::FromStr;

use aws_lambda_events::{dynamodb::EventRecord, event::dynamodb::Event};
use lambda_runtime::{run, service_fn, Error, LambdaEvent};
use serde::{Deserialize, Serialize};

#[derive(Debug, PartialEq)]
enum EventName {
    Insert,
    Modify,
    Remove,
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

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename = "StreamID")]
struct MyModel {
    #[serde(rename = "StreamID")]
    stream_id: String,
    #[serde(rename = "Online")]
    online: Option<bool>,
}

impl MyModel {
    fn get_online(self) -> bool {
        self.online.unwrap_or_default()
    }
}

async fn function_handler(event: LambdaEvent<Event>) -> Result<(), Error> {
    println!("Event: {:?}", event);
    for record in event.payload.records.iter() {
        let event_name = EventName::from_str(record.event_name.as_str()).unwrap();
        match event_name {
            EventName::Insert => {
                println!("Opertaion type {}", event_name);
                handle_insert(record).unwrap()
            }
            EventName::Modify => {
                println!("Opertaion type {}", event_name);
                handle_modify(record).unwrap()
            }
            EventName::Remove => {
                println!("Opertaion type {}", event_name);
                handle_remove(record).unwrap()
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

fn handle_insert(record: &EventRecord) -> Result<(), Error> {
    let new_image = record.change.new_image.clone();
    let new_item: MyModel = serde_dynamo::from_item(new_image)?;

    println!("NEW StreamID: {:?}", new_item.stream_id);
    println!("NEW Online Status: {:?}", new_item.get_online());

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

fn handle_remove(record: &EventRecord) -> Result<(), Error> {
    let old_image = record.change.old_image.clone();
    println!("OldImage: {:?}", old_image);
    let old_item: MyModel = serde_dynamo::from_item(old_image)?;
    println!("OldItem: {:?}", old_item);

    println!("OLD StreamID: {:?}", old_item.stream_id);
    println!("OLD Online Status: {:?}", old_item.get_online());
    Ok(())
}
