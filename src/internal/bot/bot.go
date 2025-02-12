package bot

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go/service/timestreamwrite"
	"github.com/fomiller/chat-stat/src/internal/db"
	emote "github.com/fomiller/chat-stat/src/internal/emotes"
	twitch "github.com/gempir/go-twitch-irc/v3"
	helix "github.com/nicklaw5/helix/v2"
	"golang.org/x/oauth2/clientcredentials"
	twitchAuth "golang.org/x/oauth2/twitch"
)

var (
	ClientID      string
	ClientSecret  string
	helixClient   *helix.Client
	TsWriteClient *timestreamwrite.TimestreamWrite
)

func init() {
	ClientID = os.Getenv("TWITCH_CLIENT_ID")         // password for bot account to write chat messages, need to create this programatically
	ClientSecret = os.Getenv("TWITCH_CLIENT_SECRET") // does not seem to matter

	oauth2Config := &clientcredentials.Config{
		ClientID:     ClientID,
		ClientSecret: ClientSecret,
		TokenURL:     twitchAuth.Endpoint.TokenURL,
	}

	token, err := oauth2Config.Token(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	helixClient, err = helix.NewClient(&helix.Options{
		UserAccessToken: token.AccessToken,
		ClientID:        ClientID,
	})
	if err != nil {
		panic(err)
	}

	TsWriteClient = db.NewTimeStreamClient()
}

var TwitchBot = &Bot{}

type BotList struct {
	Bots map[string]*Bot
}

type Bot struct {
	Name   string
	ID     string
	Emotes map[string]emote.Emote
	Client *twitch.Client
}

func NewBot(channel string) *Bot {
	resp, err := helixClient.GetUsers(&helix.UsersParams{
		Logins: []string{channel},
	})
	if err != nil {
		panic(err)
	}

	fmt.Printf("TWITCH USER RESP: %v\n", resp.Data)
	fmt.Printf("TWITCH USER RESP USER: %v\n", resp.Data.Users[0])
	fmt.Printf("TWITCH USER RESP USER ID: %v\n", resp.Data.Users[0].ID)
	fmt.Printf("TWITCH USER RESP USER Login: %v\n", resp.Data.Users[0].Login)
	fmt.Printf("TWITCH USER RESP USER Display Name: %v\n", resp.Data.Users[0].DisplayName)
	channelID := resp.Data.Users[0].ID
	client := twitch.NewAnonymousClient() // for an anonymous user (no write capabilities)
	client.OnPrivateMessage(PrivateMessage)
	client.Join(channel)
	return &Bot{Client: client, Name: channel, ID: channelID, Emotes: make(map[string]emote.Emote)}
}

func (b Bot) ConnectClient() {
	err := b.Client.Connect()
	if err != nil {
		panic(err)
	}
}

func PrivateMessage(message twitch.PrivateMessage) {
	messageContent := strings.Split(message.Message, " ")

	if len(message.Emotes) > 0 {
		for _, emote := range message.Emotes {
			TimeStreamInput := db.CreateTimeStreamWriteRecordInput(emote.Name, message.Channel, "twitch", message.Time.UnixMilli())
			_, err := TsWriteClient.WriteRecords(&TimeStreamInput)
			if err != nil {
				fmt.Println("ERROR Writing record to timestream db: ", err)
			}
		}
	}

	for _, word := range messageContent {
		val, ok := TwitchBot.Emotes[word]
		if ok {
			TimeStreamInput := db.CreateTimeStreamWriteRecordInput(val.GetName(), message.Channel, val.GetExtension(), message.Time.UnixMilli())
			_, err := TsWriteClient.WriteRecords(&TimeStreamInput)
			if err != nil {
				fmt.Println("ERROR Writing record to timestream db: ", err)
			}
		}
	}

}

func (b *Bot) PopulateEmotes() {
	fmt.Println("Populating Emotes")
	client := emote.NewClient()

	ffzResp := client.GetFFZEmotes(b.Name, true, true)
	fmt.Println("FFZ Resp: ", ffzResp)
	for _, e := range ffzResp {
		b.Emotes[e.GetName()] = e
	}

	bttvResp := client.GetBTTVEmotes(b.ID, true, true)
	fmt.Println("BTTV Resp: ", bttvResp)
	for _, e := range bttvResp {
		b.Emotes[e.GetName()] = e
	}

	sevenTVResp := client.Get7TVEmotes(b.ID, true, false)
	fmt.Println("7TV Resp: ", sevenTVResp)
	for _, e := range sevenTVResp {
		b.Emotes[e.GetName()] = e
	}
	fmt.Println("ALL EMOTES: ", b.Emotes)
}
