# Web scraping miniworkshop
# Riva Quiroga (@rivaquiroga, riva@rladies.org)

#packages
library(rvest)
library(tidyverse)
library(janitor)

charts_html <- read_html("https://en.wikipedia.org/wiki/List_of_best-selling_music_artists")

charts <- charts_html %>% 
  html_nodes("table") %>% 
  html_table(fill = TRUE)

View(charts)
head(charts[[6]])

charts <- charts[(1:6)]
View(charts)

names(charts[[1]])

charts[[1]] <- rename(charts[[1]], "Release-year of first charted record" = "Release year of first charted record")

names(charts[[1]])

artist_chart <- tibble(charts)
artist_chart

artist_chart <- unnest(artist_chart)
View(artist_chart)

artist_chart$`Release-year of first charted record`

artist_chart <- clean_names(artist_chart, case = "snake")

names(artist_chart)

artist_chart$release_year_of_first_charted_record

artist_chart$release_year_of_first_charted_record <- str_remove_all(artist_chart$release_year_of_first_charted_record, regex("\\[[0-9]*\\]"))

head(artist_chart)

artist_chart <- mutate(artist_chart, release_year_of_first_charted_record = as.numeric(release_year_of_first_charted_record))

head(artist_chart)

arrange(artist_chart, release_year_of_first_charted_record) %>% 
  View()

arrange(artist_chart, desc(release_year_of_first_charted_record)) %>% 
  View()


artist_chart$total_certified_units_from_available_markets_a <-  str_remove_all(artist_chart$total_certified_units_from_available_markets_a, "Total available certified units: ")

# check "datapasta": https://github.com/MilesMcBain/datapasta
