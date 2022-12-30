package timeseries

import (
	"fmt"

	redisTS "github.com/RedisTimeSeries/redistimeseries-go"
	"github.com/fomiller/chat-stat/src/internal/db"
)

func CreateTimeSeries(emote string, channel string, extension string, timestamp int64) {
	fmt.Printf("%v %v %v %v\n", timestamp, channel, extension, emote)
	options := redisTS.DefaultCreateOptions
	labels := map[string]string{
		"emote":     emote,
		"channel":   channel,
		"extension": extension,
	}
	options.Labels = labels

	key := fmt.Sprintf("%v/%v/%v", channel, extension, emote)

	db.TimeSeries.CreateKeyWithOptions(key, options)
	db.TimeSeries.AddWithOptions(key, timestamp, 1, options)
}
