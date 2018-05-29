### Template
### Open a Twitter session


library("twitteR")
library("ROAuth")


# authorisation / authentification twitter
if (!require("pacman")) install.packages("pacman")
pacman::p_load(twitteR, ROAuth, RCurl)

key = "xxxxxxxxxx"
apisecret = "xxxxxxxxxxx"
accesstoken = "xxxxxxxxxx"
accesstokensecret = "xxxxxxxxxx"

setup_twitter_oauth(key,apisecret,accesstoken,accesstokensecret)
