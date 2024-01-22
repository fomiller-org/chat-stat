// package main
//
// import (
// 	"flag"
// 	"fmt"
// 	"net"
// 	"net/http"
// 	"time"
//
// 	"github.com/aws/aws-sdk-go/aws"
// 	"github.com/aws/aws-sdk-go/aws/session"
// 	"github.com/aws/aws-sdk-go/service/timestreamwrite"
//
// 	"golang.org/x/net/http2"
// )
//
// /*
// *
//
// 	This code sample is to read data from a CSV file and ingest data into a Timestream table. Each line of the CSV file is a record to ingest.
// 	The record schema is fixed, the format is [dimension_name_1, dimension_value_1, dimension_name_2, dimension_value_2, dimension_name_2, dimension_value_2, measure_name, measure_value, measure_data_type, time, time_unit].
// 	The code will replace the time in the record with a time in the range [current_epoch_in_seconds - number_of_records * 10, current_epoch_in_seconds].
// */
// func main() {
//
// 	/**
// 	* Recommended Timestream write client SDK configuration:
// 	*  - Set SDK retry count to 10.
// 	*  - Use SDK DEFAULT_BACKOFF_STRATEGY
// 	*  - Request timeout of 20 seconds
// 	 */
//
// 	// Setting 20 seconds for timeout
// 	tr := &http.Transport{
// 		ResponseHeaderTimeout: 20 * time.Second,
// 		// Using DefaultTransport values for other parameters: https://golang.org/pkg/net/http/#RoundTripper
// 		Proxy: http.ProxyFromEnvironment,
// 		DialContext: (&net.Dialer{
// 			KeepAlive: 30 * time.Second,
// 			DualStack: true,
// 			Timeout:   30 * time.Second,
// 		}).DialContext,
// 		MaxIdleConns:          100,
// 		IdleConnTimeout:       90 * time.Second,
// 		TLSHandshakeTimeout:   10 * time.Second,
// 		ExpectContinueTimeout: 1 * time.Second,
// 	}
//
// 	// So client makes HTTP/2 requests
// 	http2.ConfigureTransport(tr)
//
// 	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1"), MaxRetries: aws.Int(10), HTTPClient: &http.Client{Transport: tr}})
// 	writeSvc := timestreamwrite.New(sess)
//
// 	// setup the query client
// 	// sessQuery, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
// 	// // querySvc := timestreamquery.New(sessQuery)
//
// 	databaseName := flag.String("database_name", "fomiller", "database name string")
// 	tableName := flag.String("table_name", "emotes", "table name string")
//
// 	flag.Parse()
//
// 	// Describe database.
// 	describeDatabaseInput := &timestreamwrite.DescribeDatabaseInput{
// 		DatabaseName: aws.String(*databaseName),
// 	}
//
// 	describeDatabaseOutput, err := writeSvc.DescribeDatabase(describeDatabaseInput)
//
// 	if err != nil {
// 		fmt.Println("Error:")
// 		fmt.Println(err)
// 		// Create database if database doesn't exist.
// 		serr, ok := err.(*timestreamwrite.ResourceNotFoundException)
// 		fmt.Println(serr)
// 		if ok {
// 			fmt.Println("Creating database")
// 			createDatabaseInput := &timestreamwrite.CreateDatabaseInput{
// 				DatabaseName: aws.String(*databaseName),
// 			}
//
// 			_, err = writeSvc.CreateDatabase(createDatabaseInput)
//
// 			if err != nil {
// 				panic(fmt.Sprintf("Error while creating database: %s", err))
// 			}
// 		}
// 	} else {
// 		fmt.Println("Database exists")
// 		fmt.Println(describeDatabaseOutput)
// 	}
//
// 	// Describe table.
// 	describeTableInput := &timestreamwrite.DescribeTableInput{
// 		DatabaseName: aws.String(*databaseName),
// 		TableName:    aws.String(*tableName),
// 	}
// 	describeTableOutput, err := writeSvc.DescribeTable(describeTableInput)
//
// 	if err != nil {
// 		fmt.Println("Error:")
// 		fmt.Println(err)
// 		serr, ok := err.(*timestreamwrite.ResourceNotFoundException)
// 		fmt.Println(serr)
// 		if ok {
// 			// Create table if table doesn't exist.
// 			fmt.Println("Creating the table")
// 			createTableInput := &timestreamwrite.CreateTableInput{
// 				DatabaseName: aws.String(*databaseName),
// 				TableName:    aws.String(*tableName),
// 			}
// 			_, err = writeSvc.CreateTable(createTableInput)
//
// 			if err != nil {
// 				panic(fmt.Sprintf("Error while creating table: %s", err))
// 			}
// 		}
// 	} else {
// 		fmt.Println("Table exists")
// 		fmt.Println(describeTableOutput)
// 	}
// 	fmt.Println("Finished")
// }
