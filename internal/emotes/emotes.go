package emotes

import (
	"net/http"
	"time"
)

type Channel struct {
	ID   string
	Name string
}

type Client struct {
	http.Client
}

func NewClient() Client {
	return Client{http.Client{Timeout: 10 * time.Second}}
}
