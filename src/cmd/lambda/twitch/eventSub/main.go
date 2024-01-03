package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodbstreams/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodbstreams/types"
)

// MyDBItem represents the structure of a DynamoDB item
type ChatStatDynamoDBItem struct {
	// Define fields based on your DynamoDB table structure
	StreamID string `dynamodbav:"StreamID" json:"StreamID"`
	Online   bool   `dynamodbav:"Online,omitempty" json:"Online"`
	// Add other fields as needed
}

func main() {
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, event events.DynamoDBEvent) {
	fmt.Printf("Event: %v\n", event)
	records, err := FromDynamoDBEvent(event)
	if err != nil {
		panic(fmt.Sprintf("Error Converting DynamoDBEvent: %s", err))
	}
	for _, record := range records {
		eventName := record.EventName
		switch eventName {
		case types.OperationTypeInsert:
			fmt.Printf("Opertaion type %s\n", eventName)
			handleInsert(record)
		case types.OperationTypeModify:
			fmt.Printf("Opertaion type %s\n", eventName)
			handleModify(record)
		case types.OperationTypeRemove:
			fmt.Printf("Opertaion type %s\n", eventName)
			handleRemove(record)
		default:
			fmt.Printf("Opertaion type not found. Operation type = %s\n", eventName)
		}
	}
}

func handleInsert(record types.Record) {
	var Item ChatStatDynamoDBItem
	newImage := record.Dynamodb.NewImage

	err := attributevalue.UnmarshalMap(newImage, &Item)
	if err != nil {
		panic(fmt.Sprintf("Error UnMarshaling MyDBItem: %s", err))
	}

	fmt.Println("StreamID:", Item.StreamID)
	fmt.Println("Online status:", Item.Online)
}

func handleModify(record types.Record) {
	var NewItem ChatStatDynamoDBItem
	var OldItem ChatStatDynamoDBItem
	newImage := record.Dynamodb.NewImage
	OldImage := record.Dynamodb.OldImage

	err := attributevalue.UnmarshalMap(newImage, &NewItem)
	if err != nil {
		panic(fmt.Sprintf("Error UnMarshaling MyDBItem: %s", err))
	}

	err = attributevalue.UnmarshalMap(OldImage, &OldItem)
	if err != nil {
		panic(fmt.Sprintf("Error UnMarshaling MyDBItem: %s", err))
	}

	fmt.Println("New StreamID:", NewItem.StreamID)
	fmt.Println("New Online status:", NewItem.Online)

	fmt.Println("Old StreamID:", OldItem.StreamID)
	fmt.Println("Old Online status:", OldItem.Online)
}

func handleRemove(record types.Record) {
	var NewItem ChatStatDynamoDBItem
	var OldItem ChatStatDynamoDBItem
	newImage := record.Dynamodb.NewImage
	OldImage := record.Dynamodb.OldImage

	err := attributevalue.UnmarshalMap(newImage, &NewItem)
	if err != nil {
		panic(fmt.Sprintf("Error UnMarshaling MyDBItem: %s", err))
	}

	err = attributevalue.UnmarshalMap(OldImage, &OldItem)
	if err != nil {
		panic(fmt.Sprintf("Error UnMarshaling MyDBItem: %s", err))
	}

	fmt.Println("New StreamID:", NewItem.StreamID)
	fmt.Println("New Online status:", NewItem.Online)

	fmt.Println("Old StreamID:", OldItem.StreamID)
	fmt.Println("Old Online status:", OldItem.Online)
}
