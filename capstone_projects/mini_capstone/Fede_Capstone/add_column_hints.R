###########################################################################################################
###                                                                                                     ###
###               Intro to function writing using dates and environmental data                          ### 
###                                                                                                     ###
###########################################################################################################

### 1. Import the data and load packages    ----------------------------------------------------------------------------------------------------------------
# Load packages
library(tidyverse)  #Contains purrr
library(lubridate)

# Load and examine data
load("capstone_projects/mini_capstone/edata_function_writing.Rdata")
head(edata)
tail(edata)
glimpse(edata)

### Goal 1: Turn 'date' into a column of 'Date' class  ------------------------------------------------------------------------------------------------------------

#~~~ HINT FOR GOAL 1: ~~~#
head(edata$date_col)
?dmy




##~~~ GENERAL HINT FOR GOALS 2 and 3: ~~~#    ---------------------------------------------------------------------------------------------------------------------

# Make a smaller edata so it will print results to console ok, easier to examine when trouble-shooting
mini_edata <- edata[2500:2600, ]
  #Now use mini_edata instead of edata in your function

#Based on this working snippet of code below (see Hints for Goal 2): 
    #you will need to define 2 arguments for the function (1) the column with dates and (2) the dataset you want to attach it to
    #or else define only 1 argument (the column with dates) and the use another method to associate the function results to your dataset...
    #this could be dplyr::mutate (i.e. for goal 2) or purrr functions (i.e. for goal 3)




### Goal 2: Add a column to edata for mon_yr using a function: WITHOUT purrr  -----------------------------------------------------------------------------------------------

##~~~ HINT FOR GOAL 2: ~~~#
#Here is how I add a column for mon_yr WITHOUT a function (i.e. I copy/paste/alter this code for each dataset I used it on)
edata$mon <- month(edata$date_col, label = T, abbr = T)
edata$yr <- year(edata$date_col)
edata$mon_yr <- paste(edata$mon, edata$yr, sep = "-")
edata$mon_yr <- factor(edata$mon_yr, levels = c("Aug-2016", 
                                                "Sep-2016", "Oct-2016", "Nov-2016", "Dec-2016",
                                                "Jan-2017", "Feb-2017", "Mar-2017", "Apr-2017",
                                                "May-2017", "Jun-2017", "Jul-2017", "Aug-2017",
                                                "Sep-2017", "Oct-2017", "Nov-2017", "Dec-2017",
                                                "Jan-2018", "Feb-2018", "Mar-2018", "Apr-2018",
                                                "May-2018", "Jun-2018", "Jul-2018", "Aug-2018"))
edata$mon_yr <- droplevels(edata$mon_yr)  #As different datasets will not all have the same months included

# Remove the 'mon_yr' column before re-making it with a function
edata <- select(edata, -mon_yr)  

#Based on this working snippet of code: 
    #what are the variables that will change between different datasets? 
    #(1) the name of the column with dates (e.g. `edata$date_col`)
    #(2) the name of the dataset (e.g. `edata`)
    #These are the inputs to your function and will be the arguments!



### GOAL 3: Alternatively, Add a column for mon_yr using a function: WITH purrr  -----------------------------------------------------------------------------------------------

##~~~ HINT FOR GOAL 3: ~~~#
#  Purrr: Example for how to use functions and 'map' and 'map_df' to return lists and data frames   #      
# (following examples all from http://www.rebeccabarter.com/blog/2019-08-19_purrr/ )                #

#Example function: addTen
addTen <- function(.x) {
  return(.x + 10)
}

# Map returns a list
map(.x = c(1, 4, 7),
    .f = addTen) 

# While map_df returns a dataframe BUT needs column names
map_df(data.frame(a = 1, b = 4, c = 7), #notice column names here
       addTen) # This works

map_df(c(1, 4, 7), #notice NO column names here
       addTen) #But this gives an error

# However, you can get around the column names thing by adding to an old data frame or another vector
map_df(c(1, 5, 7),
       function(.x){
         return(data.frame(old_number = .x,   #Notice that you are keeping your old vector of numbers here     
                           new_number = addTen(.x)))
       })

# How to use 'map' and family with tibbles (i.e. data frames where columns are LISTS)
class(edata) #notice that edata is a tibble (tbl) as well as a data.frame

tibble(list_col = list(c(1, 5, 7),
                       5,
                       c(10, 10, 11))) %>% 
  mutate(list_sum = map(list_col, sum)) %>% 
  pull(list_sum) #To get your results printed as a list, instead of staying as a tibble with columns that are lists


##~~~ MORE HINTS FOR GOAL 3: ~~~#

### Solution A: try using map_df


### Solution B: try using map with edata (or mini_edata) within another tibble
