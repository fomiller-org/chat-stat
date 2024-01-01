package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodbstreams/attributevalue"
)

type DynamoDBEvent struct {
	Records []events.DynamoDBStreamRecord `json:"Records"`
}

// MyDBItem represents the structure of a DynamoDB item
type MyDBItem struct {
	// Define fields based on your DynamoDB table structure
	StreamID string `dynamodbav:"StreamID" json:"StreamID"`
	Online   bool   `dynamodbav:"Online" json:"Online"`
	// Add other fields as needed
}

func main() {
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, event DynamoDBEvent) {
	fmt.Printf("Event: %v\n", event)
	for _, record := range event.Records {
		fmt.Printf("Record: %v\n", record)
		fmt.Printf("Record Dynamodb: %v\n", record.Dynamodb.NewImage)
		fmt.Printf("Record Dynamodb NewImage: %v\n", record.Dynamodb.NewImage)
		fmt.Printf("StreamID: %v\n", record.Dynamodb.NewImage["StreamID"])
		// var myItem2 MyDBItem
		// err := attributevalue.Unmarshal(record.Dynamodb.NewImage, &myItem2)
		// if err != nil {
		// 	fmt.Printf("Error UnMarshaling MyDBItem: %s", err)
		// }
		// fmt.Printf("Item: %v\n", myItem2)
		//
		recordData, err := attributevalue.Marshal(record.Dynamodb.NewImage)
		if err != nil {
			fmt.Printf("Error Marshaling recordData: %s", err)
		}
		fmt.Printf("Record Data: %v\n", recordData)
		var myItem MyDBItem
		err = attributevalue.Unmarshal(recordData, &myItem)
		if err != nil {
			fmt.Printf("Error UnMarshaling MyDBItem: %s", err)
		}
		fmt.Printf("Item: %v\n", myItem)

		// Process the DynamoDB item
		// Example: Print the item's ID and Name
		fmt.Println("StreamID:", myItem)
		fmt.Println("Online status:", myItem)
	}
}
