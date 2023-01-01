package main

import (
	"context"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/nicklaw5/helix/v2"
)

type Event struct {
	Name string `json:"name"`
}

func main() {
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, event Event) {
	webhookTopics := helix.GetWebhookTopicValuesFromRequest(event)
	// handle events
	if webhookTopics == helix.EventSubStreamOnlineEvent {
		// create bot and start logging chat
		// store bot id in dynamodb?
	} else if event == helix.EventSubStreamOfflineEvent {
		// disconnect bot and proccess chat data
		// kick off step function?
		// remove bot id from dynamodb?
		// cleanup redis timeseries data?
	} else {
		// event not supported
		log.Println("event not supported. Supported events EventSubStreamOfflineEvent, EventSubStreamOnlineEvent")
	}
}
