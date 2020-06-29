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
load("capstone_projects/mini_capstone/Fede_Capstone/edata_function_writing.Rdata")
head(edata)
tail(edata)
glimpse(edata)

### Goal 1: Turn 'date_col' into a column of 'Date' class  ------------------------------------------------------------------------------------------------------------

edata$date_col <- edata$date_col %>% as_date(tz = NULL, format = NULL)
sum(is.na(edata$date_col))


### Goal 2: Add a column to edata for mon_yr using a function: WITHOUT purrr  -----------------------------------------------------------------------------------------------

### Trying the potential script
edataPrueba <- edata %>% 
               select(date_col) %>% 
               mutate(mon = month(date_col, label = TRUE, abbr = TRUE), yr = year(date_col)) %>% 
               unite("monyr", mon, yr, sep = "-") %>% 
               arrange(date_col)
          


add.monyr <- function(){    
                BODY
              }




### GOAL 3: Alternatively, Add a column for mon_yr using a function: WITH purrr  -----------------------------------------------------------------------------------------------

add.monyr2 <- function(ARGUMENTorARGUMENTS){    
                  BODYofFUNCTION
                }


