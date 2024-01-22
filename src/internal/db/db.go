package db

import (
	"fmt"
	"net"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/timestreamwrite"
	"golang.org/x/net/http2"
)

var Pass = "password123!"
var Host = fmt.Sprintf("%v:%v", getEnvWithFallback("REDIS_HOST", "localhost"), "6379")
var TimeStreamDbName = "fomiller"
var TimeStreamTableName = "chat-stat"

// var TimeSeries = redisTS.NewClient(
// 	Host,
// 	"chat-stat",
// 	&Pass,
// )

func getEnvWithFallback(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

//
// var TimeSeries = redisTS.NewClient(
// 	"redis-17461.c309.us-east-2-1.ec2.cloud.redislabs.com:17461",
// 	"chat-stat",
// 	&Pass)

func NewTimeStreamClient() *timestreamwrite.TimestreamWrite {
	tr := &http.Transport{
		ResponseHeaderTimeout: 20 * time.Second,
		// Using DefaultTransport values for other parameters: https://golang.org/pkg/net/http/#RoundTripper
		Proxy: http.ProxyFromEnvironment,
		DialContext: (&net.Dialer{
			KeepAlive: 30 * time.Second,
			DualStack: true,
			Timeout:   30 * time.Second,
		}).DialContext,
		MaxIdleConns:          100,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
	}

	// So client makes HTTP/2 requests
	http2.ConfigureTransport(tr)

	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1"), MaxRetries: aws.Int(10), HTTPClient: &http.Client{Transport: tr}})
	writeSvc := timestreamwrite.New(sess)
	// Describe database.
	describeDatabaseInput := &timestreamwrite.DescribeDatabaseInput{
		DatabaseName: aws.String(TimeStreamDbName),
	}

	describeDatabaseOutput, err := writeSvc.DescribeDatabase(describeDatabaseInput)
	if err != nil {
		fmt.Println("Error:")
		fmt.Println(err)
		// Create database if database doesn't exist.
		serr, ok := err.(*timestreamwrite.ResourceNotFoundException)
		fmt.Println(serr)
		if ok {
			fmt.Println("Creating database")
			createDatabaseInput := &timestreamwrite.CreateDatabaseInput{
				DatabaseName: aws.String(TimeStreamDbName),
			}

			_, err = writeSvc.CreateDatabase(createDatabaseInput)

			if err != nil {
				panic(fmt.Sprintf("Error while creating database: %s", err))
			}
		}
	} else {
		fmt.Println("Database exists")
		fmt.Println(describeDatabaseOutput)
	}
	fmt.Println("Created WRITE SERVICE")
	return writeSvc
}

func CreateTimeStreamWriteRecordInput(emote string, channel string, extension string, timestamp int64) timestreamwrite.WriteRecordsInput {
	record := &timestreamwrite.Record{
		Dimensions: []*timestreamwrite.Dimension{
			{
				Name:  aws.String("emote"),
				Value: aws.String(emote),
			},
			{
				Name:  aws.String("extension"),
				Value: aws.String(extension),
			},
			{
				Name:  aws.String("platform"),
				Value: aws.String("twitch"),
			},
			{
				Name:  aws.String("channel"),
				Value: aws.String(channel),
			},
		},
		MeasureName:      aws.String("count"),
		MeasureValue:     aws.String("1"),
		MeasureValueType: aws.String("DOUBLE"),
		Time:             aws.String(strconv.FormatInt(timestamp, 10)),
		TimeUnit:         aws.String("MILLISECONDS"),
	}

	input := timestreamwrite.WriteRecordsInput{
		DatabaseName: aws.String(TimeStreamDbName),
		TableName:    aws.String(TimeStreamTableName),
		Records:      []*timestreamwrite.Record{record},
	}
	return input
}
