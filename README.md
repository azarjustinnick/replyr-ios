# replyr-ios

A chat app.

## MVP

A chat app that allows a user to send and view messages in a single public channel.

### Basic UI
* Text view of previous messages in channel
* Text box for username
* Text box for message
* Button to send message
* Button to fetch new messages in channel

### Basic architecture
#### Client
* iOS app
#### API
[Repository](https://github.com/azarjustinnick/replyr-api)
* Elixir
* Heroku hosted
#### Data store
* Azure DocumentDB

## Future improvements

* Web app
* Automatically display new messages
* Use push notifications to communicate new state to the app
* Identity management and auth
* Use organization for Apple credentials
* Use organization for Azure resources

## Vision
* Multiple channels with a channel switcher
* Direct messages
* Thread-based channel communication

## Terminology

* Channel
* Message
* User
