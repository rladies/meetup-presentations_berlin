
# =========================================================
# Copyright © 2019, Alison C. Holland, All rights reserved. 
# =========================================================

# This script contains the code to conduct frequency and sentiment analyses.

# website: https://www.tidytextmining.com/tidytext.html
# github: https://github.com/alisoncholland/Rladies-Text-Mining-/blob/master/Rladies_190319_textMining_v2.Rmd


# Install packages & libraries
# ----------------------------

#install.packages(c("dplyr", "tidytext", "janeaustenr", "tidyr", "igraph", "ggraph"))

library(dplyr)
library(tidytext)
library(janeaustenr)
library(tidyr)
library(igraph)
library(ggraph)


# -----------------------------
# Relationships between words
# -----------------------------


# Tokenising by n-gram
# --------------------

# add token = "n-grams" option and set n to number of words we want to capture in each n-gram, 
# e.g. n = 2 are called bigrams
# output is "bigram" column

austen_bigrams <- austen_books() %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)
austen_bigrams


# Counting and filtering n-grams
# ------------------------------

# examine most common bigrams
austen_bigrams %>%
  count(bigram, sort = TRUE)


# Removing "stop words" (common, uninteresting words) & re-count n-grams
# ----------------------------------------------------------------------

# use separate() function and then filter them
bigrams_separated <- austen_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")
bigrams_separated

# remove the "stop words"  
bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)
bigrams_filtered

# Note:
# You can also remove and add words to your list of stop words (see end of script). 


# count word frequency (without stop words)
bigram_counts <- bigrams_filtered %>% # new bigram counts
  count(book, word1, word2, sort = TRUE)
bigram_counts

# checking most common "streets" mentioned in each book (use filtered data before counted)
bigrams_filtered %>%
  filter(word2 == "street") %>%
  count(book, word1, sort = TRUE)


# Analysing bigrams - tf-idf
# --------------------------

# tf-idf stands for term frequency-inverse document frequency and is used to measure how 
# important a word is in a document compared to other documents.

# The tf-idf does this by:
# - decreasing the weight of commonly used words
# - increasing the weight of rare words to each document in a collection of documents

# e.g.
# A document containing 100 words wherein the word cat appears 3 times. 
# The term frequency (i.e., tf) for cat is then (3 / 100) = 0.03. 
# Now, assume we have 10 million documents and the word cat appears in one thousand of these. 
# Then, the inverse document frequency (i.e., idf) is calculated as log(10,000,000 / 1,000) = 4. 
# Thus, the Tf-idf weight is the product of these quantities: 0.03 * 4 = 0.12.

# recombine or unite our bigrams to their books using unite() function
bigrams_united <- bigrams_filtered %>% 
  unite(bigram, word1, word2, sep = " ")
bigrams_united

# check tf-idf 
bigram_tf_idf <- bigrams_united %>%
  count(book, bigram) %>%
  bind_tf_idf(bigram, book, n) %>%
  arrange(desc(tf_idf))
bigram_tf_idf

# plot top 15 terms in each book based on their tf-idf 
bigram_tf_idf %>%
  arrange(desc(tf_idf)) %>%
  mutate(bigram = factor(bigram, levels = rev(unique(bigram)))) %>% 
  group_by(book) %>% 
  top_n(15) %>% 
  ungroup %>%
  ggplot(aes(x = bigram, y = tf_idf, fill = book)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~ book, ncol = 2, scales = "free") +
  coord_flip()

# The graph shows 2 things:
# - the top 15 terms in each book are mostly names
# - there are some pairings of a common verb and a name, e.g. "replied Elizabeth" 


# Using bigrams to provide context in sentiment analysis
# ------------------------------------------------------

# Sentiment analysis can be done in 3 ways:

# bing - assigns "positive" and "negative" to each word
get_sentiments("bing")

# nrc - categorises each word into positive, negative, anger, anticipation, disgust, fear, joy, sadness, surprise and trust
get_sentiments("nrc")

# AFINN - assigns words with a score between -5 (negative sentiment) and 5 (positive sentiment)
get_sentiments("afinn")


# But what about bigrams with negative words, e.g. "not" in front of them? 

# filter bigrams containing the word "not" and then count frequency
bigrams_separated <- austen_books() %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(word1 == "not") %>% 
  count(word1, word2, sort = TRUE)
bigrams_separated

# define AFINN (which gives numeric sentiment score)
AFINN <- get_sentiments("afinn")

# examine the most freq words that were preceded by "not" and were associated with a sentiment
not_words <- bigrams_separated %>%
  filter(word1 == "not") %>%
  inner_join(AFINN, by = c(word2 = "word")) %>%
  count(word2, score, sort = TRUE) %>%
  ungroup()
not_words

# check which words contributed most in the "wrong" direction & plot graph
not_words %>%
  mutate(contribution = n * score) %>%
  arrange(desc(abs(contribution))) %>%
  head(20) %>%
  mutate(word2 = reorder(word2, contribution)) %>%
  ggplot(aes(word2, n * score, fill = n * score > 0)) +
  geom_col(show.legend = FALSE) +
  xlab("Words preceded by \"not\"") +
  ylab("Sentiment score * number of occurrences") +
  coord_flip()


# Visualising a network of bigrams with a "graph" a.k.a. a network
# ----------------------------------------------------------------

# check original counts
bigram_counts

# plot a "network" with ggraph to show bigrams that occurred more than 20 times and where neither word was a stop word

# filter for only relatively common combinations using graph_from_data_frame() function
bigram_graph <- bigram_counts %>%
  filter(n > 20) %>%
  graph_from_data_frame()

# set seed
set.seed(2017) 

# plot graph
ggraph(bigram_graph, layout = "fr") + 
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1)

# add a few polishing operations

# set seed
set.seed(2016) 

# add directionality with an arrow using grid::arrow()
a_direction <- grid::arrow(type = "closed", length = unit(.15, "inches")) 

# plot graph
ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), # adjusts transparency depending on common or rare words 
                 show.legend = FALSE,
                 arrow = a_direction, 
                 end_cap = circle(.07, 'inches')) + # end_cap tells the arrow to end before touching the node
  geom_node_point(color = "lightblue", size = 5) + # adding colour
  geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
  theme_void() # add a theme


# =========
# Exercises
# =========


# "Stop words" Exercise
# ---------------------

# Add or remove your own stop words and see what you get!

# e.g. removing stop words with the "setdiff" function (https://www.rdocumentation.org/packages/prob/versions/1.0-1/topics/setdiff)
# exceptions   <- c("not")
# my_stopwords <- setdiff(stopwords("en"), exceptions)

# e.g. adding stop words with the "tm_map" function (https://cran.r-project.org/web/packages/tm/tm.pdf)
# myStopwords <- c(stopwords('english'), "available", "via") to add words
# myData <- tm_map(myData, removeWords, myStopwords)


# Gutenberg Exercise
# ------------------

# Run the same code, but with the King James version of the Bible, which is Book 10 on Project Gutenberg.

#install.packages("gutenbergr")

library(gutenbergr)

# Note:
# As this is just one book and not a collection, you will need to adjust the code slightly:

# - Replace all instances of "austen_books()" with "gutenberg_download(10)"
# - Either remove the variable "book" or replace it with "gutenberg_id"


# NASA Exercise
# -------------

# Try visualising bigrams on another data set - NASA metadata. 

# See https://www.tidytextmining.com/nasa.html#how-data-is-organized-at-nasa for more info.


#install.packages("jsonlite")

library(jsonlite)

metadata <- fromJSON("https://data.nasa.gov/data.json")
names(metadata$dataset)



