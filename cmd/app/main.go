package main

import (
	"context"
	"fmt"

	redisTS "github.com/RedisTimeSeries/redistimeseries-go"
	"github.com/gempir/go-twitch-irc/v3"
)

var ctx = context.Background()
var stream = "sodapoppin"

type StreamMessage struct {
	Message string
}

func main() {
	client := twitch.NewAnonymousClient() // for an anonymous user (no write capabilities)
	rts := redisTS.NewClient("localhost:6379", "", nil)

	client.OnPrivateMessage(func(message twitch.PrivateMessage) {
		fmt.Printf("%v\n\n", message.Raw)
		for _, emote := range message.Emotes {
			extension := "twitch"
			options := redisTS.DefaultCreateOptions
			labels := map[string]string{
				"emote":     emote.Name,
				"stream":    message.Channel,
				"extension": "twitch",
			}
			options.Labels = labels

			key := fmt.Sprintf("%v/%v/%v", message.Channel, extension, emote.Name)

			rts.CreateKeyWithOptions(key, options)
			rts.AddWithOptions(key, message.Time.UnixMilli(), 1, options)
		}
	})

	client.Join(stream)
	connectClient(client)
}

func connectClient(client *twitch.Client) {
	err := client.Connect()
	if err != nil {
		panic(err)
	}
}
