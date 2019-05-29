#*********************************
# Exercise II: Working with DATA
# Example Solutions
#
# 2017
#*********************************


# start log
file.create(paste0(dir_log, "uebung_II.log"))
sink(paste0(dir_log, "uebung_II.log"), type = "output", split = TRUE)

# load ppfad dataset with labels
    # ppfad <- read.dta13(paste0(dir_stata,"ppfad.dta"), convert.factors = T)

# ********************************************************************
# we don't have the data, so lets simulate it

    # simulate ppfad
    p_sim <- data.frame(pid = 1:3000,
                    hid = rep_len(500000:500900,3000),
                    sex = sample(c(-1,-2, 0, 1), 3000, replace = TRUE),
                    qnetto = sample(-8:30, 3000, replace = T),
                    vnetto = sample(-5:30, 3000, replace = T),
                    yp0101 = sample(-2:10, 3000, replace = T))

    syear_sim <- expand.grid(pid = p_sim$pid, syear = c(1998:2010))

    ppfad <- p_sim %>% left_join(syear_sim, by = "pid") %>% arrange(hid, syear) 
    ppfad <- tbl_df(ppfad)

# ********************************************************************


#a)	How many people, who have participated in the individual questionnaire of 2000, have also participated in the 2005 survey?

# v = 2005     q = 2000 
(answ2 <- table(select(filter(ppfad, qnetto >= 10, qnetto <= 19), vnetto)))

# 8095+1+1 = 8097

# alternative 
ppfad %>% 
  filter(qnetto %>% between(10,19)) %>% 
  group_by(vnetto) %>% 
  tally()  %>% 
  as.data.frame()

# the table shows the Status of all Participants in the Year 2005, 
# only part of them (netto codes 10, 12 and 19) has still personally participated in the interview

#### Exercise 2 ####
# Recode the missing values to system-missings (NA)!

na_codes <- c(-1, -2,-3,-5,-8)
for (i in seq_along(ppfad)) {
  ppfad[[i]][ppfad[[i]] %in% na_codes] <- NA
}


#### Exercise 3 ####
# How does the average happiness with health (yp0101) differ with:

# *a) sex :
sapply(split(ppfad$yp0101, ppfad$sex), mean, na.rm = TRUE )

# alternative
ppfad %>% 
  group_by(sex) %>% 
  summarize_at(vars(yp0101), mean, na.rm= TRUE)


#### close log file ####
sink()
  


