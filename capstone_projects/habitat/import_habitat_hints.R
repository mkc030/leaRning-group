#################################################################################################
###                                                                                           ###
###       HINTS on how you might write a function for extracting landcover classes            ###
###                 For the 'habitat' function writing capstone project                       ###
###                                                                                           ###
#################################################################################################

### 1. Load packages, data, and necessary data frames  ----------------------------------------------------------------------
library(tidyverse)

load("capstone_projects/habitat/wetlands_with_landcover_as_list.Rdata")
glimpse(wtld_lc)

# Data frame for renaming landcover types
lc_names <- tibble(landcover = 0:15,
                   lc_name = c("UMD_00_water", 
                               "UMD_01_evergreen_needleleaf", 
                               "UMD_02_evergreen_broadleaf", 
                               "UMD_03_deciduous_needleleaf", 
                               "UMD_04_deciduous_broadleaf", 
                               "UMD_05_mixed_forest",
                               "UMD_06_closed_shrubland", 
                               "UMD_07_open_shrubland", 
                               "UMD_08_woody_savanna", 
                               "UMD_09_savanna", 
                               "UMD_10_grassland", 
                               "UMD_11_wetland", 
                               "UMD_12_cropland", 
                               "UMD_13_urban", 
                               "UMD_14_mosiac", 
                               "UMD_15_barren"))


### 2. Working loop on how to extract these values -----------------------------------------------------------------------
  #~I think basing your code off of this loop will probably make it easier to write a function
  #~But I haven't tried it yet myself, so may not be as helpful as I think?

#~~~ FIRST, I will write out JUST THE CODE so you can see it all together (A), 
  #and then I will go through it again explaining what it does line by line (B), 
  #and then again showing how I made sure the loop was working (C)

#~~~ BUT remember than when making the code, you'd actually be doing part (C) FIRST and THEN cleaning up the code (i.e. ending with A or B)

###~~~                 (A) Just the code                   ~~~###
spatial_list = list()
pland_list = list()

for(i in 1:length(wtld_lc)) {
  w <- as.data.frame(wtld_lc[i])
  
  for(j in 1:ncol(w)){
    
    w.values <- count(w, w[ ,j])
    w.values <- mutate(w.values, pland = n / sum(n))

    names(w.values)[1] <- "landcover"
    w.values <- full_join(w.values, lc_names, by = "landcover")
    
    wtld_yr <- rep(names(w)[j], times = nrow(w.values))
    w.values <- cbind(wtld_yr, w.values)

    w.values$n[which(is.na(w.values$n))] <- 0
    w.values$pland[which(is.na(w.values$pland))] <- 0

    w.values <- arrange(w.values, landcover)

    pland_list[[j]] <- w.values
    
    print(names(w)[j])
  }
  spatial_list[[i]] <- bind_rows(pland_list)
  print(names(wtld_lc)[i])
}

wtld_all_lc <- bind_rows(spatial_list)


###~~~                 (B) Code with explainations                   ~~~###

#~~~ 2i) For a loop - you need to start by making an empty object to put the result of the loop into
# Make an empty list for dataframes of each wetland
spatial_list = list()

# Make an empty list for frequency counts and pland values for each wetland_year combo
pland_list = list()

#~~~ 2ii) Then you need to determine what you are trying to loop through
  #~I find it helps me to look at the structure and first element of my list that I am trying to loop through 
  #~in order to figure this out
  str(wtld_lc, max.level = 2) #I usually start with max.level = 2 or else you can get a GIANT print out in your console
  wtld_lc[[1]]
  #~In this case we are wanting to loop through each wetland and each year within each wetland
  

#Loop through each element (wetland) in wtld_lc to make a data frame
  #Making a data frame is necessary or else dplyr::count won't work
for(i in 1:length(wtld_lc)) {
  w <- as.data.frame(wtld_lc[i])

  #Loop through each year (i.e. column) within the data frame in the list of wetlands
  for(j in 1:ncol(w)){
    
#~~ 2iii) Then figure out what you want your loop to do. This is the bit we want our function to do for us!
    #So within each wetland-year
    #This next bit of code counts the frequency of each landcover type
    #And then 
    
    #Determine the frequency of each landclass, per year (column) in this wetland
    w.values <- count(w, w[ ,j])
    w.values <- mutate(w.values, pland = n / sum(n))
    
    #Rename the landcover column, then join to the landcover name data frame
    names(w.values)[1] <- "landcover"
    w.values <- full_join(w.values, lc_names, by = "landcover")
    
    #Add a column identifying the wetland and year combination
    wtld_yr <- rep(names(w)[j], times = nrow(w.values))
    w.values <- cbind(wtld_yr, w.values)
    
    #Replace counts and pland of landcover classes that are not present with '0' 
    w.values$n[which(is.na(w.values$n))] <- 0
    w.values$pland[which(is.na(w.values$pland))] <- 0
    
    #Arrange the data frame in order of UDM landcover class to keep it easier to read
    w.values <- arrange(w.values, landcover)
    
    #Place the wtld_yr combination dataframe of count of landcover and PLAND into 
      #it's own element inside 'test_list'
    pland_list[[j]] <- w.values
    
    #Print something so you know where the loop gets to, in case it fails part way through
    print(names(w)[j])
  }

  # Turn the list into a dataframe
  spatial_list[[i]] <- bind_rows(pland_list)
  
  #Print something so you know where the loop gets to, in case it fails part way through
  print(names(wtld_lc)[i])
}
  
  #This loop will give you a bunch of warnings, it is just about turning your factors into characters 
    #so dplyr can bind the rows together. THis is fine (and good...). You can safely ignore the warnings.
  
# Now turn the spatial list into one data frame...notice this bit is OUTSIDE of the loop, and uses what you made in your loop
  wtld_all_lc <- bind_rows(spatial_list)
  

###~~~            (C) Code with hints on working through developing loops               ~~~###
  # I assume we can do something similar for functions as well...
  # I basically assign an expected value to each "temporary" value that will be used in the loop or function
  # Then I step through each line of code (except for the loop bit) to make sure the code works
  # And that the output is the value I expect
  
  #For instance our loop has 'wtld_lc', 'i', 'j' as temporary inputs 
    #(and you should reset your lists where you are placing the results of your lists to be empty again too)
    #So to see if my code seems to work, I would run the following in the console:
  
#make sure you make a copy of your original dataset so you don't mess it up!!!!   
wtld_lc_org <- wtld_lc  
  
#Now assign the temporary variables
wltd_lc <- wtld_lc_org[[1]]
i = 1
j = 1

#Reset your "return" objects to be empty (as you would be doing this just before the start of your loop in Step2)
spatial_list = list()
pland_list = list()

#Now step through each part of your loop line by line - checking what the objects are after (and sometimes before) running the code
  #is each bit of code is doing what you expect?
w <- as.data.frame(wtld_lc[i])
w

w.values <- count(w, w[ ,j])
w.values

w.values <- mutate(w.values, pland = n / sum(n))
w.values

names(w.values)
names(w.values)[1] <- "landcover"
names(w.values)

w.values <- full_join(w.values, lc_names, by = "landcover")
w.values

wtld_yr <- rep(names(w)[j], times = nrow(w.values))
wtld_yr

w.values <- cbind(wtld_yr, w.values)
w.values

sum(is.na(w.values$n))
w.values$n[which(is.na(w.values$n))] <- 0
sum(is.na(w.values$n))

sum(is.na(w.values$pland))
w.values$pland[which(is.na(w.values$pland))] <- 0
sum(is.na(w.values$pland))

w.values
w.values <- arrange(w.values, landcover)
w.values

pland_list[[j]] <- w.values
pland_list[[j]]

print(names(w)[j])

spatial_list[[i]] <- bind_rows(pland_list)
spatial_list[[i]]

print(names(wtld_lc)[i])

wtld_all_lc <- bind_rows(spatial_list)
wtld_all_lc

#And then I do it all again a few times with different values of temporary variables
#for example
wltd_lc <- wtld_lc_org[[1]]
i = 2
j = 3

#and then run through the loop code above line by line again

#for example #2
wltd_lc <- wtld_lc_org[[5]]
i = 1
j = 1

#and then run through the loop code above line by line again

#If it all works, success!!! And much rejoicing :)




### 3. Final hints/guesses as to what might work well for turning that loop into a function -------------------------------

#I think we will have to write our own function for calculating PLAND values, based on the code in the loop
#Then use a purrr function (`map_df` or `map_dfr` maybe? could also use something from baseR like sapply) 
  #to apply that function across our list

