package main

import (
	"context"
	"fmt"
	"os"

	"github.com/fomiller/chat-stat/src/internal/bot"
)

// var RTSDB = redisTS.NewClient("localhost:6379", "", nil)
var ctx = context.Background()
var exit = make(chan int)

func main() {
	channel := os.Getenv("TWITCH_CHANNEL")
	bot.TwitchBot = bot.NewBot(channel)
	bot.TwitchBot.PopulateEmotes()
	go bot.TwitchBot.ConnectClient()

	<-exit
	fmt.Println("Shutting down.")
}
