install.packages("wordcloud")
install.packages("tm")

library("wordcloud")
library("tm")

# to retrieve tweets from a specific hashtag
tweets <- searchTwitter("RLadies", n=500)

# convert the tweets to df
tweets.df <- twListToDF(tweets)
head(tweets.df)

# create a text corpus
myCorpus <- Corpus(VectorSource(tweets.df$text))

# lower the characters
myCorpus <- tm_map(myCorpus,content_transformer(function(x) iconv(x, to='UTF-8-MAC', sub='byte')))
myCorpus <- tm_map(myCorpus, content_transformer(tolower))

# remove the URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))

# remove punctuation
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))

# remove most common English words + words I define
myStopwords <- c(setdiff(stopwords('english'), c("r", "big")),
                 "use", "see", "used", "via", "amp")
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

# Strip extra whitespace from a text document. 
# Multiple whitespace characters are collapsed to a single blank.
myCorpus <- tm_map(myCorpus, stripWhitespace)

# convert the document to a document matrix
tdm <- TermDocumentMatrix(myCorpus,control = 
                            list(weighting = function(x) weightTfIdf (x, normalize =FALSE)))
m <- as.matrix(tdm)
word.freq <- head(sort(rowSums(m), decreasing = T),150)

########################
# create the wordcloud #
########################
# sequential palettes
# Blues BuGn BuPu GnBu Greens Greys Oranges OrRd PuBu PuBuGn PuRd Purples RdPu Reds
# YlGn YlGnBu YlOrBr YlOrRd

pal <- brewer.pal(9, "Oranges")
pal <- pal[-(1:6)]

wordcloud(words = names(word.freq), freq = word.freq, min.freq = 1.5,
          random.order = F, colors = pal)