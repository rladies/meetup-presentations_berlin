set.seed(610)

df <- as.data.frame(round(runif(1000, 0, 1)))
names(df) <- c('name')
df$species_draw <- runif(1000, 0, 3)
df$days <- round(runif(1000, 1, 365))
df$random_fun <- round(runif(1000, 0, 1))
df$died <- round(((df$random_fun) + (df$species_draw))/2) # Determines whether has died or not, depending on species
df$died <- abs(round(ifelse(df$days <=100,
                            (df$died)-(df$name), #Having a name can save it during the 100 first days
                            df$died)))
df$died <- ifelse(df$died==-1, 0, df$died)
df$species_round <- round(df$species_draw)
df$species <- ifelse(df$species_round == 0, 'cactus', 'geranium')
df$species <- ifelse(df$species_round == 1, 'basil', df$species)
df$species <- ifelse(df$species_round == 2, 'pachira', df$species)
df <- df[ -c(2,4,6) ]
df$name <- ifelse(df$name == 1, TRUE, FALSE)
df$died <- ifelse(df$died == 0, FALSE, TRUE)
df$days <- as.numeric(df$days)

df <- df[,c(1,4,2,3)]