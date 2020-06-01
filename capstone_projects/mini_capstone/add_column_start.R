###########################################################################################################
###                                                                                                     ###
###               Intro to function writing using dates and environmental data                          ### 
###                                                                                                     ###
###########################################################################################################

### Import the data and load packages    ----------------------------------------------------------------------------------------------------------------
# Load packages
library(tidyverse)  #Contains purrr
library(lubridate)

# Load and examine data
load("capstone_projects/mini_capstone/edata_function_writing.Rdata")
head(edata)
tail(edata)
glimpse(edata)

### Goal 1: Turn 'date_col' into a column of 'Date' class  ------------------------------------------------------------------------------------------------------------





### Goal 2: Add a column to edata for mon_yr using a function: WITHOUT purrr  -----------------------------------------------------------------------------------------------

add_monyr <- function(ARGUMENTorARGUMENTS){    
                BODYofFUNCTION
              }




### GOAL 3: Alternatively, Add a column for mon_yr using a function: WITH purrr  -----------------------------------------------------------------------------------------------

add_monyr2 <- function(ARGUMENTorARGUMENTS){    
                  BODYofFUNCTION
                }


