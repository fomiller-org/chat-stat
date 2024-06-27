## Todo
[x] connect bot
[] webserver endpoints
[] redis locally
[] connect multiple bots, one per channel of top 100 followed streams, or one for every 20
[] find api of all emotes, bttv emotes, 7tv emotes?
[] api endpoint of most followed channels
[] allow for streamer to add their channel to bot list, some sort of auth needed here
[] infrastructure
[] docker setup
[] write messages to redis if containing emote
[] redis scaling
[] server scaling
[] cicd
[] cache data points to form a graph that can be rendered by a front end
[] standard deviation of points on graph
[] create clip, A, B, versions. 15sec, 30 sec
[] chat-stat cli

## 7tv emote endpoints
https://api.7tv.app/v2/emotes/global

## bttv emote endpoints
limit 100

- top
    https://api.betterttv.net/3/emotes/shared/top?offset=0&limit=100
- trending
    https://api.betterttv.net/3/emotes/shared/trending?offset=0&limit=100
- global
    https://api.betterttv.net/3/cached/emotes/global
- shared
    https://api.betterttv.net/3/cached/emotes/shared

https://api.7tv.app/v2/emotes/global

## Twitch emotes
curl -X GET 'https://api.twitch.tv/helix/chat/emotes/global' \
-H 'Authorization: Bearer cfabdegwdoklmawdzdo98xt2fo512y' \
-H 'Client-Id: uo6dggojyb8d6soh92zknwmi5ej1q2'

## Webhooks
webhooks for when a streamer goes on and offline, this could trigger a lambda?
https://dev.twitch.tv/docs/eventsub/eventsub-reference
- stream offline condition 
- stream online condition

## helix endpoint
curl -X GET 'https://api.twitch.tv/v5/videos/1681900380/comments?content_offset_seconds=1' \
-A "Accept: application/vnd.twitchtv.v5+json; charset=UTF-8" \
-H 'Client-Id: kimne78kx3ncx6brgo4mv6wki5h1ko'\

# Running locally
- start redis service
`brew service start redis`
- test redis database is Running
`redis-cli `
