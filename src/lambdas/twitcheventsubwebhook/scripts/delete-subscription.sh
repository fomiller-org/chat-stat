#!/bin/bash
ID=$1
curl -sX DELETE "https://api.twitch.tv/helix/eventsub/subscriptions?id=${ID}" \
-H "Authorization: Bearer $TWITCH_TOKEN" \
-H "Client-Id: $TWITCH_CLIENT_ID" \
-H "Content-Type: application/json"
