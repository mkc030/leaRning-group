#################################################################################################
###                                                                                           ###
###                       'habitat' function writing capstone project                         ###
###                                                                                           ###
#################################################################################################

### 1. Load packages------------------------------------------------------------------------------------------------------------------------------
library(tidyverse) #Note dplyr masks 'raster' extract() and select() functions
library(viridis) #For prettier plot colors

load("capstone_projects/habitat/wetlands_with_landcover_as_list.Rdata")
glimpse(wtld_lc)

### 2. Make data frames that might be useful to function and capstone goals ----------------------------------------------------------------------

# Make a data frame that provides more detailed UMD landcover names
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

# Make a data frame of all the wetland abbreviations used
  #I didn't actually use this in my current code, but it might be helpful for troubleshooting
  #or possibly necessary for the function (and/or graphing), depending on how you want to write it
all.wtlds <- c("JAC", "LAX", "WBC",
               "BHER", "BRY", "BURN", "LMT",
               "MIL", "MNP", "NIC", "PIT", 
               "REI", "SAR", "SDW", "SFEN", 
               "SIS", "STA", "TRL", "TUY",
               "TWU", "WCK")

### 3. Write a function to calculate the PLAND and turn the list into a dataframe! ---------------------------------------------------------------

### Function version #A: just wrap double loops inside a function

#   'm.extract.pland' FUNCTION                                                                       
#   This function transforms the number of times a given landcover classification is listed for a wetland-year combination
#     into a PLAND (Proporation of LANDcover) value for each landcover, per unique wetland-year combination
#   Inputs: MyList = a list with one element per wetland, each containing one column per year that hold the landcover
#                    value for each cell extracted by a spatial merge from a MODIS raster file
#           MyVars = a data frame that contains one column with the landcover number (0:15 for UMD classification system)
#                    and one column with character strings representing each landcover number (e.g. "water")

m.extract.pland <- function(MyList, MyVars = lc_names) {
  spatial_list = list()
  pland_list = list()
  
  for(i in seq_along(MyList)) {  
    w <- as.data.frame(MyList[i]) #This call ONLY works if have ONE MyWtld named, otherwise fails
    #I can turn w into a list with names using w <- as.list(w)
    #Perhaps can then turn this loop into another function???
    for(j in 1:ncol(w)){
      w.values <- count(w, w[ ,j])
      w.values <- mutate(w.values, pland = n / sum(n)) #Note the 'n' here is a column name made by 'count', NOT the dplyr 'n()' function
      names(w.values)[1] <- "landcover"
      w.values <- full_join(w.values, MyVars, by = "landcover")
      wtld_yr <- rep(names(w)[j], times = nrow(w.values))
      w.values <- cbind(wtld_yr, w.values)
      w.values$n[which(is.na(w.values$n))] <- 0
      w.values$pland[which(is.na(w.values$pland))] <- 0
      w.values <- arrange(w.values, landcover)
      #w.values$wtld <- rep(MyWtld, times = nrow(w.values)) #Need to double check this line works
      pland_list[[j]] <- w.values
      #print(names(w)[j])   #Unhash only if troubleshooting the loop
    }
    spatial_list[[i]] <- bind_rows(pland_list)
    #print(names(MyList)[i])   #Unhash only if troubleshooting the loop
  }
  wtld_all_lc <- bind_rows(spatial_list)
}


wtld_df <- m.extract.pland(MyList = wtld_lc,
                           MyVars = lc_names)


### Check it looks ok...
head(wtld_df)
tail(wtld_df)
table(wtld_df$lc_name)/3 #We expect each landcover type 21 times per year (or 63 = 21 wetlands * 3 years); hooray!


### Functions version #B: I was trying to use PURRR and/or nested tibbles but it didn't really work out
#   so instead have ended up with two new functions that just use more code and no real increase in work efficiency. Ah well.


#   'm.wlist.to.df' FUNCTION
#   This function pulls elements out of a list and turns them into a dataframe by binding rows
#   Inputs: MyList = a list with one element per wetland, each containing one column per year that hold the landcover
#                    value for each cell extracted by a spatial merge from a MODIS raster file
#           MyWtld = a character vector of wetland names; should match the names of all wetland elements in the MyList object

#For testing first function
#MyList <- wtld_lc[1:2]
#MyWtld <- c("BHER", "BRY")

m.wlist.to.df <- function(MyList, MyWtld){
  pland_list = list()
  K <- length(MyWtld)
  for(i in 1:K){
    w <- as.data.frame(pluck(MyList, MyWtld[i])) #Needs to turn into a data frame give the matrix column names for purrr to work
    w$wtld <- rep(MyWtld[i], times = nrow(w)) 
    pland_list[[i]] <- w  
  }
  names(pland_list) <- MyWtld 
  wtld_df <- reduce(pland_list, bind_rows)
}

#t <- m.wlist.to.df(MyList = MyList, MyWtld = MyWtld)
wtld_df <- m.wlist.to.df(MyList = wtld_lc, MyWtld = all.wtlds)


#   'm.add.pland' FUNCTION
#   This function adds the PLAND (Proportion of LANDcover) values for each wetland-year combination to the data frame
#     generated by the 'm.wlist.to.df' function
#   Inputs: MyDf = the data frame generated by the 'm.wlist.to.df' function
#           YrCols = a vector of character strings of the column names in the MyDf object for each year
#           LcDf = a data frame that contains one column with the landcover number (0:15 for UMD classification system)
#                  and one column with character strings representing each landcover number (e.g. "water")

#Testing second part of the function
#test <- filter(wtld_df, wtld == "BHER" | wtld == "BRY")

m.add.pland <- function(MyDf, YrCols, LcDf){
  
  #Make a "long" dataset
  long_data <- pivot_longer(MyDf,
                          cols = all_of(YrCols),
                          names_to = "years",
                          values_to = "landcover")
                          #names_prefix = "y") #If I wanted to get rid of the "y" part in the years column...but then messes up the rest of the function
  
  #Calculate plands
  w.values <- long_data %>%
               group_by(wtld, years, landcover) %>% 
               summarize(n = n()) %>%  #Note here I am naming a new column 'n' based on the 'n()' function
               ungroup() %>% 
      
               group_by(wtld, years) %>% 
               mutate(pland = n / sum(n)) #Here I am using the column named 'n' NOT the 'n()' function
  
  #Join landcover names and put in zeros for any missing values 
  w.names <- unique(MyDf$wtld)
  L <- length(unique(LcDf$landcover))
  l.nums <- unique(LcDf$landcover)
  l.names <- unique(LcDf$lc_name)
  
  lc_list <- list()
  yr_list <- list()
  
  for(i in seq_along(w.names)){
    for(j in seq_along(YrCols)){
      yr_list[[j]] <- data.frame(wtld = c(rep(w.names[i], times = L)),
                                 years = c(rep(YrCols[j], times = L)),
                                 landcover = c(l.nums),
                                 lc_name = c(l.names))
                                 #n = c(rep(0, times = L)),       #If wanted to add zeros in at this stage
                                 #pland = c(rep(0, times = L)))   #If wanted to add zeros in at this stage
      }
      lc_list[[i]] <- bind_rows(yr_list)
    }
  lc_wtld_yr <- bind_rows(lc_list)
  
  #Now join the dataframe with landcover names back to the dataframe with calculated PLANDs
  w.values <- full_join(w.values, lc_wtld_yr, by = c("wtld", "years", "landcover"))  
  w.values$n[which(is.na(w.values$n))] <- 0
  w.values$pland[which(is.na(w.values$pland))] <- 0
  
  #Organize so it is easier to read if you use 'View' or 'glimpse'
  w.values <- arrange(w.values, wtld, years, landcover)
}

#For testing with a subset of wtld_lc
#t2 <- m.add.pland(MyDf = test, 
#                  YrCols = c("y2016", "y2017", "y2018"), 
#                  LcDf = lc_names)

wtld_df2 <- m.add.pland(MyDf = wtld_df, 
                       YrCols = c("y2016", "y2017", "y2018"), 
                       LcDf = lc_names)
          #It is ok to ignore the warnings, this is just wetlands being coerced from factors back to character strings when joining datasets

### Check it looks ok...
head(wtld_df2)
tail(wtld_df2)
table(wtld_df2$lc_name)/3 #We expect each landcover type 21 times per year (or 63 = 21 wetlands * 3 years); hooray!


# What should this look like in the end?
load("capstone_projects/habitat/wetlands_landcover_loop_result.Rdata")
glimpse(wtld_all_lc)
#My results from functions A and B are similar but not exactly the same. Close enough for what I want anyways so I'm happy.


### 4. Keep only the dominant (i.e. highest proportion) pland for each wetland_year -------------------------------------------------------------
    #And turn this into a "wide" data frame where each row is a unique wetland-year combination


#I already found a solution that works for me (in the 'import_habitat_full.R' script) so I won't repeat here




### 5. Graph the results of either step 3 or step 4  --------------------------------------------------------------------------------------------

  #I will make a heatmap of PLAND values from step 3 using the 'wtld_df' object (); made using function option A (m.extract.pland)

### First, need to change some of the names in the 'lc_name' column so it plots nicely
# Remove the 'UMD_##_' prefix
wtld_df$lc_name <- str_sub(wtld_df$lc_name, start = 8)

# Shorten the remaining character strings in the name
wtld_df$lc_name <- str_replace(wtld_df$lc_name, pattern = "evergreen_needleleaf", replacement = "evergreen_nleaf")
wtld_df$lc_name <- str_replace(wtld_df$lc_name, pattern = "evergreen_broadleaf", replacement = "evergreen_bleaf")
wtld_df$lc_name <- str_replace(wtld_df$lc_name, pattern = "deciduous_needleleaf", replacement = "deciduous_nleaf")
wtld_df$lc_name <- str_replace(wtld_df$lc_name, pattern = "deciduous_broadleaf", replacement = "deciduous_bleaf")
wtld_df$lc_name <- str_replace(wtld_df$lc_name, pattern = "closed_shrubland", replacement = "shrub_closed")
wtld_df$lc_name <- str_replace(wtld_df$lc_name, pattern = "open_shrubland", replacement = "shurb_open")

# Add a column with just wetland name for facetting; can extract by separating the 'wtld_yr' column
wtld_df <- separate(wtld_df, 
                    col = wtld_yr,  #This is the name of the column I want to separate into two different columns
                    into = c("wtld", NA), #Don't want to keep the part after the period, so put NA for the second column 
                    sep = "\\.",   #This argument is based on a regular expression, so need to escape the period, and another escape for the first backslash
                    remove = F)    #Still want to keep the original 'wtld_yr' column

### Second, plot with ggplot
ggplot(wtld_df, aes(x = lc_name, y = wtld_yr, fill = pland)) +
  geom_tile() +
  facet_grid(wtld ~ ., scales = "free_y", space = "free_y") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_viridis(discrete = F)








