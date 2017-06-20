install.packages("needs")
library(needs)
needs(tidyr,dplyr,ggplot2,readxl)
setwd("/Users/MarieLou/Desktop")
# data from http://inkar.de/
data <- read_excel("inkar.xls", na="NA")
head(data)
data.new <- gather(data, key="key", value="value", 3:10)
# differences in mean east / west germany
data.new %>% group_by(Raumeinheit,key) %>% dplyr::summarize(mean=mean(value, na.rm=T)) %>% spread(key=Raumeinheit, value=mean) %>% mutate(diff=abs(Ost-West))
# change in unemployment over years
unemply <- data.new %>% filter(key %in% "Arbeitslosigkeit")
ggplot(unemply, aes(x=Jahr,y=value,color = Raumeinheit)) +
  geom_point() + geom_line()
  