package emotes

import (
	"encoding/json"
	"fmt"
)

type FFZEmote struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type FFZSet struct {
	ID     int        `json:"id"`
	Title  string     `json:"title"`
	Emotes []FFZEmote `json:"emoticons"`
}

type FFZResponse struct {
	Sets map[string]FFZSet `json:"sets"`
}

func (c Client) GetFFZUserEmotes(channel string) (FFZResponse, error) {
	var emotes FFZResponse

	endpoint := fmt.Sprintf("https://api.frankerfacez.com/v1/room/%v", channel)
	resp, err := c.Get(endpoint)
	if err != nil {
		return FFZResponse{}, err
	}
	defer resp.Body.Close()

	decoder := json.NewDecoder(resp.Body)
	decoder.Decode(&emotes)
	if err != nil {
		return FFZResponse{}, err
	}

	return emotes, nil
}

func (c Client) GetFFZGlobalEmotes() (FFZResponse, error) {
	var emotes FFZResponse

	endpoint := "https://api.frankerfacez.com/v1/set/global"

	resp, err := c.Get(endpoint)
	if err != nil {
		return FFZResponse{}, err
	}
	defer resp.Body.Close()

	decoder := json.NewDecoder(resp.Body)
	decoder.Decode(&emotes)
	if err != nil {
		return FFZResponse{}, err
	}

	return emotes, nil
}
