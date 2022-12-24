package db

import (
	redisTS "github.com/RedisTimeSeries/redistimeseries-go"
)

var TimeSeries = redisTS.NewClient("localhost:6379", "", nil)
