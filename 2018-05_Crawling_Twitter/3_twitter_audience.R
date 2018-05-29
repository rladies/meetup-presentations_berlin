install.packages("dplyr")
library('dplyr')

# extract my followers
my_name <- "RLadiesBerlin"
me <- getUser(my_name)
my_followers <- me$getFollowers()
my_followers <- twListToDF(my_followers)

# we can't extract pretected accounts
# so, to avoid a crash in the extraction
# we limit the extraction to non-protected accounts

my_followers <-subset(my_followers, protected==FALSE)
head(my_followers)

# initialise a dataframe with my_followers

twitter.audience <-data.frame(source=my_followers$screenName,
                              target=my_name,
                              N=me$followersCount,
                              loc=me$location,
                              stringsAsFactors=FALSE)

##### DON'T RUN THIS LOOP #######


# let's consider that if my followers have more than 5000 friends, it's not a real friendship
# so we'll ignore them in the extraction
# because they're time consuming
skipped.friends <- NULL
friends.threshold <- 5000

#######################
# the extraction loop #
#######################

for (friend.name in my_followers$screenName) {
  ## extract my friends data
  friend <- getUser(friend.name, retryOnRateLimit=180) # rate limit, because the amount of calls on the Twitter API
                                                       # is limited per hour
                                                       # if we exceed this treshold, the extraction crashes
       
  ## skip accounts with more than 5000 friends
  if (friend$friendsCount > friends.threshold) {
    message(paste("*** skipping", friend.name, " (too many friends) ***"))
    skipped.friends <- append(skipped.friends, friend.name)
    next
  } else {
    message(friend.name)
  }
  
  ## extract my followers friendships
  friend.friends <- friend$getFriends(retryOnRateLimit=180)
  
  ## only evaluate the ones who have friends
  if (length(friend.friends) > 0) {
    friend.friends <- twListToDF(friend.friends)
    ## only create a link with my followers, and ignore the other friendships
    common.friends <- intersect(c(my_followers$screenName, my_name), friend.friends$screenName)
    if (length(common.friends) > 0)
      twitter.audience <- rbind(twitter.audience,
                              data.frame(source=friend.name,
                                         target=common.friends,
                                         N=friend$followersCount,
                                         loc=friend$location,
                                         stringsAsFactors=FALSE))
  }
}



write.table(twitter.audience, "twitter_followers_RLadies.csv", na ="",quote =F, sep =";",
            row.names = F, col.names=T)

#### START HERE #######

twitter.audience<-read.table("twitter_followers_RLadies.csv", sep=";", header=T)

#compute communities
install.packages("igraph")
library(igraph)

# create a gephi graph
g <- graph.edgelist(as.matrix(twitter.audience[,c(1,2)]), directed=FALSE)


# compute communities with Louvain algorithm
communities<-cluster_louvain(g, weights = NULL)
V(g)$groups = communities$membership
g<-g - c("RLadiesBerlin")
table(communities$membership)


#############################################################################
# create a node and an edge file to process the data visualisation in Gephi #
#############################################################################
my_edges<-as.data.frame(cbind(Source=twitter.audience$source,Target=twitter.audience$target))

#nodes list for Gephi
Nb_followers<-my_followers %>% dplyr::select(screenName,followersCount)
groups<-as.data.frame(cbind(Id=seq(length(communities$membership)), 
                            Label=communities$names, 
                            Group=communities$membership))
Nb_followers<-my_followers %>% select(screenName,followersCount)
groups<-merge(groups,Nb_followers, by.x="Label", by.y="screenName", all.x=T)
write.table(groups,"nodes_twitter.csv",quote =F, sep =";",row.names = F)

#edge list for Gephi
my_edges<-merge(my_edges,groups,by.x="Source",by.y="Label",all.x=T)
my_edges<-merge(my_edges,groups,by.x="Target",by.y="Label",all.x=T)
my_edges<-my_edges %>%dplyr::select(Id.x,Id.y)
colnames(my_edges)<-c("Source","Target")
write.table(my_edges, "edges_twitter.csv", na ="",quote =F, sep =";",row.names = F, col.names=T)
