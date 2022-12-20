package main

import (
	"context"
	"fmt"
	"strings"

	"github.com/gempir/go-twitch-irc/v3"
	"github.com/go-redis/redis/v9"
	"github.com/google/uuid"
)

var ctx = context.Background()

type StreamMessage struct {
	Message string
}

func main() {
	client := twitch.NewAnonymousClient() // for an anonymous user (no write capabilities)
	rdb := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	client.OnPrivateMessage(func(message twitch.PrivateMessage) {
		for _, emote := range message.Emotes {
			id, _ := uuid.NewRandom()
			streamChannelName := fmt.Sprintf("%v_%v", message.Channel, strings.ToLower(emote.Name))

			// add emote to stream without consumer
			err := rdb.XAdd(ctx, &redis.XAddArgs{
				Stream: streamChannelName,
				MaxLen: 5,
				Approx: false,
				ID:     "",
				Values: []interface{}{"message", fmt.Sprintf("%v %v %v - %v", message.Time.String(), emote.Name, emote.Count, id)},
			}).Err()
			if err != nil {
				panic(err)
			}

			// examples of how to use XLEN
			// fmt.Printf("the length is : %v\n", rdb.XLen(ctx, "swolenesss_kappa").Val())
			// fmt.Printf("the length is : %v\n", rdb.XLen(ctx, "swolenesss_pogchamp").Val())

			// publish message to channel that has a subscriber attached will automatically be consumed
			err = rdb.Publish(ctx, streamChannelName, fmt.Sprintf("%v %v %v - %v", message.Time.String(), emote.Name, emote.Count, id)).Err()
			if err != nil {
				panic(err)
			}
		}
	})

	client.Join("swolenesss")
	go connectClient(client)
	// There is no error because go-redis automatically reconnects on error.
	pubsub := rdb.Subscribe(ctx, "swolenesss_kappa")
	// Close the subscription when we are done.
	defer pubsub.Close()
	ch := pubsub.Channel()

	for msg := range ch {
		fmt.Println(msg.Payload)
	}

}

func connectClient(client *twitch.Client) {
	err := client.Connect()
	if err != nil {
		panic(err)
	}
}
