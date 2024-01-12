#!/bin/bash
curl -X POST 'https://api.twitch.tv/helix/eventsub/subscriptions' \
-H "Authorization: Bearer $TWITCH_TOKEN" \
-H "Client-Id: $TWITCH_CLIENT_ID" \
-H "Content-Type: application/json" \
-d '{"type":"stream.online","version":"1","condition":{"broadcaster_user_id":"26301881"},"transport":{"method":"webhook","callback":"https://6rm4cdx6bizoo6jsdxatsontnm0sgiym.lambda-url.us-east-1.on.aws/", "secret":"s3cre77890ab"}}' 
