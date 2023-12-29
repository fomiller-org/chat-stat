package db

import (
	"fmt"
	"os"

	redisTS "github.com/RedisTimeSeries/redistimeseries-go"
)

var Pass = "password123!"
var Host = fmt.Sprintf("%v:%v", getEnvWithFallback("REDIS_HOST", "localhost"), "6379")

var TimeSeries = redisTS.NewClient(
	Host,
	"chat-stat",
	&Pass,
)

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
