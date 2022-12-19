package main

import (
	"log"

	"github.com/gempir/go-twitch-irc/v3"
)

func main() {
	client := twitch.NewAnonymousClient() // for an anonymous user (no write capabilities)

	client.OnPrivateMessage(func(message twitch.PrivateMessage) {
		log.Println(message.Message)
	})

	client.Join("sodapoppin")

	err := client.Connect()
	if err != nil {
		panic(err)
	}
}
