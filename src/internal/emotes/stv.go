package emote

import (
	"encoding/json"
	"fmt"
	"log"
)

type STVEmote struct {
	Name      string `json:"name"`
	ID        string `json:"id"`
	Extension string
}

func (e STVEmote) GetName() string {
	return e.Name
}

func (e STVEmote) GetID() string {
	return e.ID
}

func (e STVEmote) GetExtension() string {
	return e.Extension
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
	for i := range emotes {
		emotes[i].Extension = "7tv"
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
	for i := range emotes {
		emotes[i].Extension = "7tv"
	}

	return emotes, nil
}

func (c Client) GetSTVEmotes(user string, channel bool, global bool) []Emote {
	var emotes = []Emote{}

	if channel {
		res, err := c.GetSTVUserEmotes(user)
		if err != nil {
			log.Println(err)
		}
		for _, e := range res {
			emotes = append(emotes, e)
		}
	}

	if global {
		res, err := c.GetSTVGlobalEmotes()
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
