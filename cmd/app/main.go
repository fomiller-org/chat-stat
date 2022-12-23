package main

import (
	"context"
	"fmt"

	redisTS "github.com/RedisTimeSeries/redistimeseries-go"
	"github.com/gempir/go-twitch-irc/v3"
)

var ctx = context.Background()
var stream = "moonmoon"

type StreamMessage struct {
	Message string
}

func main() {
	client := twitch.NewAnonymousClient() // for an anonymous user (no write capabilities)
	// rdb := redis.NewClient(&redis.Options{
	// 	Addr:     "localhost:6379",
	// 	Password: "", // no password set
	// 	DB:       0,  // use default DB
	// })

	rts := redisTS.NewClient("localhost:6379", "", nil)

	client.OnPrivateMessage(func(message twitch.PrivateMessage) {
		for _, emote := range message.Emotes {
			extension := "twitch"
			options := redisTS.DefaultCreateOptions
			labels := map[string]string{
				"emote":     emote.Name,
				"stream":    message.Channel,
				"extension": "twitch",
			}
			options.Labels = labels

			fmt.Println(labels)

			key := fmt.Sprintf("%v/%v/%v", message.Channel, extension, emote.Name)

			rts.CreateKeyWithOptions(key, options)

			rts.AddWithOptions(key, message.Time.UnixMilli(), 1, options)

			// examples of how to use XLEN
			// fmt.Printf("the length is : %v\n", rdb.XLen(ctx, "swolenesss_kappa").Val())
			// fmt.Printf("the length is : %v\n", rdb.XLen(ctx, "swolenesss_pogchamp").Val())

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
