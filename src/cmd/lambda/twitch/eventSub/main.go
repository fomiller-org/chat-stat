package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type DynamoDBEvent struct {
	Records []events.DynamoDBEventRecord `json:"Records"`
}

// DynamoDBItem represents the structure of a DynamoDB item
type DynamoDBItem struct {
	// Define fields based on your DynamoDB table structure
	StreamID string `json:"StreamID"`
	Online   bool   `json:"Online"`
	// Add other fields as needed
}

func main() {
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, event DynamoDBEvent) {
	fmt.Printf("Event: %v\n", event)

	for _, record := range event.Records {
		recordData, err := json.Marshal(record.Change.NewImage)
		if err != nil {
			panic(fmt.Sprintf("Error Marshaling recordData: %s", err))
		}
		// Unmarshal DynamoDB record data
		var myItem DynamoDBItem
		err = json.Unmarshal(recordData, &myItem)
		if err != nil {
			panic(fmt.Sprintf("Error UnMarshaling DynamoDBItem: %s", err))
		}

		// Process the DynamoDB item
		// Example: Print the item's ID and Name
		fmt.Println("StreamID:", myItem.StreamID)
		fmt.Println("Online status:", myItem.Online)
	}
}
