#*********************************
# Master Skript
# start with this script
#
# 2017
#*********************************

# enable soft-wrap to display script well (Tools -> Global Options -> Code)

# In Order for R to have the correct Path, 
# RStudio should not be running prior to opening this script. 
# If RStudio is opened through opening the master script from your personal folder, 
# it will automatically store the correct path for your further work. 
# You can check the stored path with getwd() and change it with setwd(), in case there are problems.


#### install missing packages and load needed packages ####

  # packages that are needed can be added underneath
  p_needed <- c("readr", # import spreadsheet data
              "magrittr", # for piping
              "haven", # imports SPSS, Stata and SAS files
              "ggplot2", # for graphics
              "tidyr",
              "descr",
              "stringr", # to manipulate/ work with strings
              "janitor", # to clean dataframes
              "readstata13", # to read Stata Data into R
              "rstudioapi",
              "dplyr",
              "plm",  # panel regression analysis
              "memisc",
              "stargazer",  # output of regression results in Latex tables
              "tidyverse" # includes the packages important for every day data analyses
              )
  

  packages <- rownames(installed.packages())
  p_to_install <- p_needed[!(p_needed %in% packages)]
  if (length(p_to_install) > 0) {
   install.packages(p_to_install)
  }
  lapply(p_needed, require, character.only = TRUE)


#***********************************************
# Set relative paths to the working directory
#***********************************************
  # finds and sets the directory of the executed script
  # this code finds the local repository in which the R-script is executed,
    dir_home <- dirname(rstudioapi::callFun("getActiveDocumentContext")$path) 
    setwd(dir_home) 
  # other directories
  dir_log   <- "H:/Lehre/something/R scripte/log/"  # path to log dir
  dir_stata <- "H:/Lehre/something/SOEP32_core_50/" # path to data
  dir_out   <- "H:/Lehre/something/R scripte/output/" # path to output dir
  
  getwd() # displays working dir

  