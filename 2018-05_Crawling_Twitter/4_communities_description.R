##################################
# visualise the user description #
##################################
groups<-as.data.frame(cbind(names=communities$names,membership=communities$membership))

my_followers<-merge(my_followers,groups,by.x="screenName", by.y="names")
my_followers$membership<-as.factor(my_followers$membership)

for (i in levels(my_followers$membership)){
  my_corpus<-subset(my_followers$description, my_followers$membership==i)
  myCorpus <- Corpus(VectorSource(my_corpus))
  removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
  myCorpus <- tm_map(myCorpus, removeURL)
  myCorpus <- tm_map(myCorpus, removeWords, words = stopwords("english"))
  myCorpus <- tm_map(myCorpus,content_transformer(function(x) iconv(x, to='UTF-8-MAC', sub='byte')))
  myCorpus <- tm_map(myCorpus, content_transformer(tolower))
  myCorpus <- tm_map(myCorpus, removePunctuation)
  myCorpus <- tm_map(myCorpus, function(x)removeWords(x,stopwords()))
  tdm <- TermDocumentMatrix(myCorpus,control = list(weighting = function(x) weightSMART(x, spec = "ntc")))
  m <- as.matrix(tdm)
  word.freq <- head(sort(rowSums(m), decreasing = T),500)
  name_group<- paste0("group_",i)
  assign(paste0("tdm_",name_group), word.freq) 
}

for (i in grep("tdm_",ls(),value=TRUE)){
  print(i)
  png(paste0("wordcloud_",i,".png"), width=800,height=800)
  w_count<-get(i)
  print(w_count)
  wordcloud(words = names(w_count), scale=c(8,.1), min.freq = 4,rot.per=.5,freq = w_count, random.order = F)
  dev.off()
}