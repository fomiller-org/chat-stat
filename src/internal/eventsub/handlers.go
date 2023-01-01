package eventsub

import "github.com/nicklaw5/helix/v2"

func HandleNotifcation(notification eventSubNotification) {

}

func HandleStreamOnlineEvent(callback func(event helix.EventSubStreamOnlineEvent)) {

}

func HandleStreamOfflineEvent(callback func(event helix.EventSubStreamOfflineEvent)) {

}
