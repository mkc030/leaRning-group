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

### Goal 1:  Turn 'date' into a column of 'Date' class  ------------------------------------------------------------------------------------------------------------
edata <- mutate(edata, date_col = dmy(date_col))
glimpse(edata)


### Goal 2 and 3: Add a column to edata for mon_yr using a function: WITHOUT purrr  -----------------------------------------------------------------------------------------------
add.monyr <- function(dates, mydata){    
  mn <- month(dates, label = T, abbr = T)
  yr <- year(dates)
  mon_yr <- paste(mn, yr, sep = "-")
  mydata$mon_yr <- mon_yr
  mydata$mon_yr <- factor(mydata$mon_yr, levels = c("Aug-2016", 
                                                    "Sep-2016", "Oct-2016", "Nov-2016", "Dec-2016",
                                                    "Jan-2017", "Feb-2017", "Mar-2017", "Apr-2017",
                                                    "May-2017", "Jun-2017", "Jul-2017", "Aug-2017",
                                                    "Sep-2017", "Oct-2017", "Nov-2017", "Dec-2017",
                                                    "Jan-2018", "Feb-2018", "Mar-2018", "Apr-2018",
                                                    "May-2018", "Jun-2018", "Jul-2018", "Aug-2018"))
  mydata$mon_yr <- droplevels(mydata$mon_yr)
  return(mydata)
}

edata <- add.monyr(dates = edata$date_col, mydata = edata) 
glimpse(edata)

edata <- select(edata, -mon_yr)  #Remove the 'mon_yr' column before re-making it with another function


### Goal 3: Alternatively, Add a column for mon_yr using a function: WITH purrr  -----------------------------------------------------------------------------------------------
# Make a smaller edata so it will print results to console ok, easier to examine
mini_edata <- edata[2500:2600, ]

### Goal 3, solution A: using map_df
# Define another function based on structure used in examples above
add.monyr2 <- function(.x){    
  mn <- month(.x, label = T, abbr = T)
  yr <- year(.x)
  mon_yr <- paste(mn, yr, sep = "-")
  mon_yr <- factor(mon_yr, levels = c("Aug-2016", 
                                      "Sep-2016", "Oct-2016", "Nov-2016", "Dec-2016",
                                      "Jan-2017", "Feb-2017", "Mar-2017", "Apr-2017",
                                      "May-2017", "Jun-2017", "Jul-2017", "Aug-2017",
                                      "Sep-2017", "Oct-2017", "Nov-2017", "Dec-2017",
                                      "Jan-2018", "Feb-2018", "Mar-2018", "Apr-2018",
                                      "May-2018", "Jun-2018", "Jul-2018", "Aug-2018"))
  #mydata$mon_yr <- droplevels(mydata$mon_yr)   #Doesn't make sense to drop factor levels until joined to a dataset
  return(mon_yr)
}


fdates <- map_df(mini_edata$date_col,
                function(.x){
                  return(data.frame(date_col = .x,   #Notice that you are keeping your old vector of numbers here     
                                    mon_yr = add.monyr2(.x)))
                })
glimpse(fdates)
fdates <- unique(fdates) #If don't select down to only the unique combinations, you get WAY too many rows when you join

#Now join mini_edata to factored dates, based on date_col
e.new <- full_join(mini_edata, fdates, by = "date_col")

#And drop levels now
e.new$mon_yr <- droplevels(e.new$mon_yr)

#Examine new object; should only have 2 levels for mon_yr in e.new (as it is a SUBSET of the original edata)
glimpse(e.new)
levels(e.new$mon_yr)


### Goal 3, solution B: using map and tibbles
#Example to work from
tibble(list_col = list(c(1, 5, 7),
                       5,
                       c(10, 10, 11))) %>% 
  mutate(list_sum = map(list_col, sum)) %>% 
  pull(list_sum) #To get your results printed as a list, instead of staying as a tibble with columns that are lists

#My attempt to use this method
e.new2 <- mini_edata %>% 
          mutate(mon_yr = map(date_col, add.monyr2)) 

glimpse(e.new2)
      #hmmm...this returns mon_yr as a LIST...which is not ideal...would work with map_chr if I was not trying to save as an ordered factor within the function

#Let's try again with a modified function (withOUT ordering the factor) so can use map_chr and not get new column as a list 
add.monyr3 <- function(.x){    
  mn <- month(.x, label = T, abbr = T)
  yr <- year(.x)
  mon_yr <- paste(mn, yr, sep = "-")
  #mon_yr <- factor(mon_yr, levels = c("Aug-2016", 
  #                                    "Sep-2016", "Oct-2016", "Nov-2016", "Dec-2016",
  #                                    "Jan-2017", "Feb-2017", "Mar-2017", "Apr-2017",
  #                                    "May-2017", "Jun-2017", "Jul-2017", "Aug-2017",
  #                                    "Sep-2017", "Oct-2017", "Nov-2017", "Dec-2017",
  #                                    "Jan-2018", "Feb-2018", "Mar-2018", "Apr-2018",
  #                                    "May-2018", "Jun-2018", "Jul-2018", "Aug-2018"))
  #mydata$mon_yr <- droplevels(mydata$mon_yr)   #Doesn't make sense to drop factor levels until joined to a dataset
  return(mon_yr)
}

e.new3 <- mini_edata %>% 
  mutate(mon_yr = map_chr(date_col, add.monyr3)) 

glimpse(e.new3) #Better

#But now still need to turn this into an ordered factor by copying and pasting code
e.new3$mon_yr <- factor(e.new3$mon_yr, levels = c("Aug-2016", 
                                    "Sep-2016", "Oct-2016", "Nov-2016", "Dec-2016",
                                    "Jan-2017", "Feb-2017", "Mar-2017", "Apr-2017",
                                    "May-2017", "Jun-2017", "Jul-2017", "Aug-2017",
                                    "Sep-2017", "Oct-2017", "Nov-2017", "Dec-2017",
                                    "Jan-2018", "Feb-2018", "Mar-2018", "Apr-2018",
                                    "May-2018", "Jun-2018", "Jul-2018", "Aug-2018"))
glimpse(e.new3)
levels(e.new3$mon_yr)

#Drop missing levels
e.new3$mon_yr <- droplevels(e.new3$mon_yr)
glimpse(e.new3)
levels(e.new3$mon_yr)
  

#These all WORK but when using purrr I still need to do more external coding (i.e. turning into a factor and dropping levels) AFTER running/writing the function...
  #so probably my very first solution WITHOUT purrr is probably the best option for what I want to do (i.e. with the least amount of copy/paste/change code)


