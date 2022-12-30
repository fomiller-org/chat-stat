package emote

import (
	"encoding/json"
	"fmt"
	"log"
)

type BTTVEmote struct {
	Name      string `json:"code"`
	ID        string `json:"id"`
	Extension string
}

func (e BTTVEmote) GetName() string {
	return e.Name
}

func (e BTTVEmote) GetID() string {
	return e.ID
}

func (e BTTVEmote) GetExtension() string {
	return e.Extension
}

type BTTVResponse []BTTVEmote

type BTTVChannelResponse struct {
	SharedEmotes  []BTTVEmote `json:"sharedEmotes"`
	ChannelEmotes []BTTVEmote `json:"channelEmotes"`
}

func (c Client) GetBTTVUserEmotes(channel string) (BTTVChannelResponse, error) {
	var res BTTVChannelResponse

	endpoint := fmt.Sprintf("https://api.betterttv.net/3/cached/users/twitch/%v", channel)
	resp, err := c.Get(endpoint)
	if err != nil {
		return BTTVChannelResponse{}, err
	}
	defer resp.Body.Close()

	decoder := json.NewDecoder(resp.Body)
	decoder.Decode(&res)
	if err != nil {
		return BTTVChannelResponse{}, err
	}

	for i := range res.SharedEmotes {
		res.SharedEmotes[i].Extension = "bttv"
	}
	for i := range res.ChannelEmotes {
		res.ChannelEmotes[i].Extension = "bttv"
	}

	return res, nil
}

func (c Client) GetBTTVGlobalEmotes() (BTTVResponse, error) {
	var res BTTVResponse

	endpoint := "https://api.betterttv.net/3/cached/emotes/global"
	resp, err := c.Get(endpoint)
	if err != nil {
		return nil, err
	}

	defer resp.Body.Close()

	decoder := json.NewDecoder(resp.Body)
	decoder.Decode(&res)
	if err != nil {
		return nil, err
	}
	for i := range res {
		res[i].Extension = "bttv"
	}

	return res, nil
}

func (c Client) GetBTTVEmotes(user string, channel bool, global bool) []Emote {
	var emotes = []Emote{}
	if channel {
		res, err := c.GetBTTVUserEmotes(user)
		if err != nil {
			log.Println(err)
		}
		for _, e := range res.ChannelEmotes {
			emotes = append(emotes, e)
		}
		for _, e := range res.SharedEmotes {
			emotes = append(emotes, e)
		}
	}

	if global {
		res, err := c.GetBTTVGlobalEmotes()
		if err != nil {
			log.Println(err)
		}
		for _, e := range res {
			emotes = append(emotes, e)
		}
	}

	return emotes
}
