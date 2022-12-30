package main

import (
	"context"
	"fmt"
	"os"

	redisTS "github.com/RedisTimeSeries/redistimeseries-go"
	"github.com/fomiller/chat-stat/src/internal/bot"
)

var RTSDB = redisTS.NewClient("localhost:6379", "", nil)
var ctx = context.Background()
var exit = make(chan int)

func main() {
	file, err := os.Open("channels.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	bot.ConnectBots(file, bot.Bots)

	<-exit
	fmt.Println("Shutting down.")
}
