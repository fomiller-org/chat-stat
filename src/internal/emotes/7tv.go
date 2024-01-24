package emote

import (
	"encoding/json"
	"fmt"

	"github.com/seventv/common/structures/v3"

	// "go.mongodb.org/mongo-driver/bson"
	"io/ioutil"
	"log"
)

type SevenTVEmote struct {
	Name      string `json:"name"`
	ID        string `json:"id"`
	Extension string
}

type SevenTVEmoteSet struct {
	Name      string              `json:"name"`
	ID        string              `json:"id"`
	EmoteSet  structures.EmoteSet `json:"emote_set"`
	Extension string
}

type MyEmote struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	Flags     int64  `json:"flags"`
	Timestamp int64  `json:"timestamp"`
}

type EmoteSet struct {
	ID         string        `json:"id"`
	Name       string        `json:"name"`
	Tags       []interface{} `json:"tags"`
	Immutable  bool          `json:"immutable"`
	Privileged bool          `json:"privileged"`
	Emotes     []MyEmote     `json:"emotes,omitempty"`
	Capacity   int64         `json:"capacity"`
}

type SevenTVChannelEmotes struct {
	ID            string   `json:"id"`
	Platform      string   `json:"platform"`
	Username      string   `json:"username"`
	DisplayName   string   `json:"display_name"`
	LinkedAt      int64    `json:"linked_at"`
	EmoteCapacity int64    `json:"emote_capacity"`
	EmoteSet      EmoteSet `json:"emote_set"`
}

func (e SevenTVEmote) GetName() string {
	return e.Name
}

func (e SevenTVEmote) GetID() string {
	return e.ID
}

func (e SevenTVEmote) GetExtension() string {
	return e.Extension
}

type MyResponse struct {
	EmoteSet structures.EmoteSet `json:"emote_set"`
}

type SevenTVResponse []SevenTVEmote

func (c Client) Get7TVUserEmotes(channelID string) (SevenTVChannelEmotes, error) {
	// https://7tv.io/v3/users/twitch/26301881 // endpoint for getting sodapoppin emotes
	// will have to get channel.id from twich api to make this call
	// https://7tv.io/v3/users/{platform [twitch,youtube,kick,etc]}/{channel id from platform}

	endpoint := fmt.Sprintf("https://7tv.io/v3/users/%s/%s", "twitch", channelID)
	response, err := c.Get(endpoint)
	if err != nil {
		return SevenTVChannelEmotes{}, err
	}
	defer response.Body.Close()

	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		fmt.Println("Error reading response body:", err)
		return SevenTVChannelEmotes{}, err
	}

	var emotes SevenTVChannelEmotes
	err = json.Unmarshal(body, &emotes)
	if err != nil {
		return SevenTVChannelEmotes{}, fmt.Errorf("failed to unmarshal emotes: %v", err)
	}
	fmt.Println("EMOTESET: ", emotes)
	fmt.Println("EMOTESET EMOTES: ", emotes.EmoteSet.Emotes)
	fmt.Println("TOTAL EMOTES", len(emotes.EmoteSet.Emotes))
	fmt.Println("EMOTES: ", emotes)

	return emotes, nil
}

func (c Client) Get7TVGlobalEmotes() (SevenTVResponse, error) {
	var emotes SevenTVResponse

	endpoint := "https://api.7tv.app/v2/emotes/global"
	resp, err := c.Get(endpoint)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	decoder := json.NewDecoder(resp.Body)
	decoder.Decode(&emotes)
	if err != nil {
		return nil, err
	}
	for i := range emotes {
		emotes[i].Extension = "7tv"
	}

	return emotes, nil
}

func (c Client) Get7TVEmotes(channelID string, channel bool, global bool) []Emote {
	fmt.Println("7tv ChannelID:", channelID)
	var emotes = []Emote{}

	if channel {
		res, err := c.Get7TVUserEmotes(channelID)
		fmt.Println("GET USER EMOTES RES: ", res)
		if err != nil {
			log.Println(err)
		}
		for _, e := range res.EmoteSet.Emotes {
			emotes = append(emotes, SevenTVEmote{Name: e.Name, ID: e.ID, Extension: "7tv"})
		}
	}

	if global {
		res, err := c.Get7TVGlobalEmotes()
		if err != nil {
			log.Println(err)
		}

		for _, e := range res {
			emotes = append(emotes, e)
		}
	}
	fmt.Println("7tv", emotes)

	return emotes
}
