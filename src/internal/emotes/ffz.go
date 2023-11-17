package emote

import (
	"encoding/json"
	"fmt"
	"log"
	"strconv"
)

type FFZEmote struct {
	ID        int    `json:"id"`
	Name      string `json:"name"`
	Extension string
}

func (e FFZEmote) GetName() string {
	return e.Name
}

func (e FFZEmote) GetID() string {
	return strconv.Itoa(e.ID)
}

func (e FFZEmote) GetExtension() string {
	return e.Extension
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
	for i := range emotes.Sets {
		for ii := range emotes.Sets[i].Emotes {
			emotes.Sets[i].Emotes[ii].Extension = "ffz"
		}
	}
	// fmt.Println("test", emotes)

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

	for i := range emotes.Sets {
		for ii := range emotes.Sets[i].Emotes {
			emotes.Sets[i].Emotes[ii].Extension = "ffz"
		}
	}

	return emotes, nil
}

func (c Client) GetFFZEmotes(user string, channel bool, global bool) []Emote {
	var emotes = []Emote{}

	if channel {
		res, err := c.GetFFZUserEmotes(user)
		if err != nil {
			log.Println(err)
		}
		for _, s := range res.Sets {
			for _, e := range s.Emotes {
				emotes = append(emotes, e)
			}
		}
	}

	if global {
		res, err := c.GetFFZGlobalEmotes()
		if err != nil {
			log.Println(err)
		}
		for _, s := range res.Sets {
			for _, e := range s.Emotes {
				emotes = append(emotes, e)
			}
		}
	}

	return emotes
}
