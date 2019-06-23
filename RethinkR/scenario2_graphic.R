# Scenario 2

# Graph is from German Newspaper, found in an article on which moods are associated with different kinds of alcohol
# article can be found here: https://www.zeit.de/wissen/gesundheit/2017-11/alkoholkonsum-studie-schnaps-wein-bier-beeinflussung-stimmung

# (credits to Fabian Gülzau who used this example in a dataviz course)

# Pakete laden
library(tidyverse)

# Daten laden
alcohol <- read.csv(file = file.choose(), header = TRUE, stringsAsFactors = FALSE, sep = ";", encoding = "UTF-8")

# OR no download needed
alcohol <- read_delim("https://raw.githubusercontent.com/rladies/meetup-presentations_berlin/master/RethinkR/Zeit_data.csv", ";")
    
glimpse(alcohol)

alcohol_long <- alcohol %>%
  gather(spirits, red.wine, white.wine, beer, 
         key = drink, 
         value = approval) %>%
  mutate(characteristic = as_factor(X.1))
  

# Plot
ggplot(data = alcohol_long, 
       mapping = aes(x = X.1, y = approval, color = drink)) +
  geom_point(stat = "identity", size = 3) +
  coord_flip() +
  labs(y = "Approval Regarding Mood in Percent",
       x = "", 
       caption = "Source: Global Drug Survey, British Medical Journal"
  ) +
  scale_color_manual(values = c("yellow2", "red","deepskyblue2", "gray")
  ) +
  theme_minimal()
