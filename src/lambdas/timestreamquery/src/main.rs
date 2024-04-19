use aws_config::BehaviorVersion;
use lambda_runtime::{run, service_fn, tracing, Error, LambdaEvent};
use serde::{Deserialize, Serialize};

use strum_macros::EnumString;

#[derive(Deserialize, Debug)]
struct Request {
    query_type: String,
    channel: Option<String>,
    time: Option<String>,
    limit: Option<String>,
    bin_time: Option<String>,
}

#[derive(Serialize)]
struct Response {
    msg: String,
}

#[derive(strum_macros::Display, Deserialize, Debug, EnumString)]
#[strum(serialize_all = "snake_case")]
enum QueryType {
    #[strum(to_string = "ToPeMOte")]
    TopEmote {
        query: String,
    },
    TopMoments {
        channel: String,
    },
}

#[derive(strum_macros::Display, Deserialize, Debug, EnumString)]
#[strum(serialize_all = "snake_case")]
enum QuerySchedule {
    Daily,
    Weekly,
    Monthly,
    Yearly,
}

#[derive(strum_macros::Display, Deserialize, Debug, EnumString)]
#[strum(serialize_all = "snake_case")]
enum TimestreamQuery {
    TopMomentsByChannel(String),
    TopMomentsCrossChannel(String),
}

async fn function_handler(event: LambdaEvent<Request>) -> Result<Response, Error> {
    // Extract some useful info from the request
    println!("{:?}", event.payload);
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region("us-east-1")
        .load()
        .await;

    let query_client = aws_sdk_timestreamquery::Client::new(&config)
        .with_endpoint_discovery_enabled()
        .await?;

    let query = match event.payload.query_type.to_lowercase().as_str() {
        "top_moments_by_channel" => Ok(TimestreamQuery::TopMomentsByChannel(format!(
            r#"
            SELECT emote, count(emote) AS emote_count 
            FROM fomiller.chat_stat 
            WHERE channel='{}' 
                AND time > ago({}) 
            GROUP BY emote ORDER BY emote_count DESC LIMIT {}
            "#,
            event.payload.channel.expect("missing channel for query"),
            event.payload.time.expect("missing time for query"),
            event.payload.limit.expect("missing limit for query"),
        ))),
        "top_moments_cross_channel" => {
            let binned_timestamp = event.payload.bin_time.expect("missing channel for query");
            let time = event.payload.time.expect("missing time for query");
            let limit = event.payload.limit.expect("missing limit for query");
            Ok(TimestreamQuery::TopMomentsCrossChannel(format!(
                r#"
                SELECT BIN(time, {}) AS binned_timestamp, count(emote) AS emote_count, emote, channel
                FROM fomiller.chat_stat
                WHERE measure_name = 'count'
                    AND time > ago({})
                GROUP BY BIN(time, {}), emote, channel
                ORDER BY emote_count DESC LIMIT {}
                "#,
                binned_timestamp, time, binned_timestamp, limit,
            )))
        }
        _ => Err(format!(
            "TimestreamQuery not supported: {}",
            event.payload.query_type
        )),
    }?;

    let res = match query {
        TimestreamQuery::TopMomentsByChannel(q) => {
            query_client.0.query().query_string(q).send().await
        }
        TimestreamQuery::TopMomentsCrossChannel(q) => {
            query_client.0.query().query_string(q).send().await
        }
    };

    match res {
        Ok(r) => {
            let x: Vec<_> = r
                .rows()
                .into_iter()
                .map(|r| r.data().into_iter().map(|d| return d).collect::<Vec<_>>())
                .collect();
            for v in x {
                println!("TIME: {:?}", v[0].scalar_value().unwrap());
                println!("EMOTE_COUNT: {:?}", v[1].scalar_value().unwrap());
                println!("EMOTE: {:?}", v[2].scalar_value().unwrap());
                println!("CHANNEL: {:?}\n", v[3].scalar_value().unwrap())
            }
        }
        Err(e) => {
            eprintln!("{:?}", e.as_service_error());
        }
    }

    let resp = Response {
        msg: format!("success {}", "hellow"),
    };

    Ok(resp)
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    run(service_fn(function_handler)).await
}
