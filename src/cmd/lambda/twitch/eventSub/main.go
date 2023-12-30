package main

import (
	"context"
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type DynamoDBEvent struct {
	Records []events.DynamoDBEventRecord `json:"Records"`
}

// MyDynamoDBItem represents the structure of a DynamoDB item
type MyDynamoDBItem struct {
	// Define fields based on your DynamoDB table structure
	ID   string `json:"ID"`
	Name string `json:"Name"`
	// Add other fields as needed
}

func main() {
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, event DynamoDBEvent) error {
	println("hello event sub")
	println("Event:", event)

	for _, record := range event.Records {
		// Unmarshal DynamoDB record data
		var myItem MyDynamoDBItem
		err := json.Unmarshal(record.Change.NewImage, &myItem)
		if err != nil {
			return err
		}

		// Process the DynamoDB item
		// Example: Print the item's ID and Name
		println("ID:", myItem.ID)
		println("Name:", myItem.Name)
	}
	return nil
}
