#!/bin/bash
curl -sX GET 'https://api.twitch.tv/helix/eventsub/subscriptions' \
-H "Authorization: Bearer $TWITCH_TOKEN" \
-H "Client-Id: $TWITCH_CLIENT_ID" \
-H "Content-Type: application/json"
