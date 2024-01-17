## Commands
### to login
```
twitch token
export TWITCH_TOKEN=<token>
```
### run cmd
```
doppler run -- <cmd>
```
### take 1st id of subscriptions and delete
```
doppler run -- ./scripts/list-subscriptions.sh | jq -r '.data[0].id' | doppler run -- xargs ./scripts/delete-subscription.sh
echo $TWITCH_CLIENT_ID
```
### list all subscription ids
```
doppler run -- ./scripts/list-subscriptions.sh | jq '.data[].id'
```
### list number of subscriptions
```
doppler run -- ./scripts/list-subscriptions.sh | jq '.data | length'
```

## docs
https://dev.twitch.tv/docs/cli/event-command/
