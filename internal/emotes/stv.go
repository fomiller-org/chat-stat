package emotes

import (
	"encoding/json"
	"fmt"
)

type STVEmote struct {
	Name string `json:"name"`
	ID   string `json:"id"`
}

type STVResponse []STVEmote

func (c Client) GetSTVUserEmotes(channel string) (STVResponse, error) {
	var emotes STVResponse
	endpoint := fmt.Sprintf("https://api.7tv.app/v2/users/%v/emotes", channel)
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

func (c Client) GetSTVGlobalEmotes() (STVResponse, error) {
	var emotes STVResponse

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

	return emotes, nil
}
