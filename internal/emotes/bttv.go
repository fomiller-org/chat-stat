package emotes

import (
	"encoding/json"
	"fmt"
)

type BTTVEmote struct {
	Name string `json:"code"`
	ID   string `json:"id"`
}
type BTTVResponse []BTTVEmote
type BTTVChannelResponse struct {
	SharedEmotes  []BTTVEmote
	ChannelEmotes []BTTVEmote
}

func (c Client) GetBTTVUserEmotes(channel string) (BTTVResponse, error) {
	var res BTTVChannelResponse
	var emotes BTTVResponse

	endpoint := fmt.Sprintf("https://api.betterttv.net/3/cached/users/twitch/%v", channel)
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

	emotes = append(emotes, res.SharedEmotes...)
	emotes = append(emotes, res.ChannelEmotes...)

	return emotes, nil
}

func (c Client) GetBTTVGlobalEmotes() (BTTVResponse, error) {
	var emotes BTTVResponse

	endpoint := "https://api.betterttv.net/3/cached/emotes/global"
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

	return emotes, nil
}
