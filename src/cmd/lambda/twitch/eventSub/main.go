package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	// "github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodbstreams/attributevalue"
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
	for _, record := range event.Records {
		recordData, err := attributevalue.MarshalMap(record.Change.NewImage)
		if err != nil {
			fmt.Printf("Error Marshaling recordData: %s", err)
		}
		fmt.Printf("Record Data: %v\n", recordData)
		// // Unmarshal DynamoDB record data
		var myItem DynamoDBItem
		err = attributevalue.UnmarshalMap(recordData, &myItem)
		if err != nil {
			fmt.Printf("Error UnMarshaling DynamoDBItem: %s", err)
		}
		fmt.Printf("Item: %v\n", myItem)

		// Process the DynamoDB item
		// Example: Print the item's ID and Name
		fmt.Println("StreamID:", myItem.StreamID)
		fmt.Println("Online status:", myItem.Online)
	}
}
