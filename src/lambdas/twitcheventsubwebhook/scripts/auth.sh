#!/bin/bash
curl -X POST "https://api.twitch.tv/helix/auth/token?client_id=${TWITCH_CLIENT_ID}&client_secret=${TWITCH_CLIENT_SECRET}&grant_type=client_credentials"
