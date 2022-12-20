package main

import (
	"context"
	"log"
	"fmt"

	"github.com/gempir/go-twitch-irc/v3"
	"github.com/go-redis/redis/v9"
)

var ctx = context.Background()

func main() {
	client := twitch.NewAnonymousClient() // for an anonymous user (no write capabilities)
	rdb := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	client.OnPrivateMessage(func(message twitch.PrivateMessage) {
		log.Println(message.Message)
		err := rdb.Publish(ctx, message.Channel, message.Message).Err()
		if err != nil {
			panic(err)
		}
	})

	client.Join("moonmoon")
	go connectClient(client)
	// There is no error because go-redis automatically reconnects on error.
	pubsub := rdb.Subscribe(ctx, "mychannel1")
	// Close the subscription when we are done.
	defer pubsub.Close()
	ch := pubsub.Channel()

	for msg := range ch {
		fmt.Println(msg.Channel, msg.Payload)
	}
	
}

func connectClient(client *twitch.Client) {
	err := client.Connect()
	if err != nil {
		panic(err)
	}
}
