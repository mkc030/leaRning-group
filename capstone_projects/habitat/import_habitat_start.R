#################################################################################################
###                                                                                           ###
###                       'habitat' function writing capstone project                         ###
###                                                                                           ###
#################################################################################################

### 1. Load packages-------------------------------------------------------------------------------------------------------------
library(tidyverse) #Note dplyr masks 'raster' extract() and select() functions

load("capstone_projects/habitat/wetlands_with_landcover_as_list.Rdata")
glimpse(wtld_lc)

### 2. Make data frames that might be useful to function and capstone goals ----------------------------------------------

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

### 3. Write a function to calculate the PLAND and turn the list into a dataframe!
  #I renamed the landcover types using lc_names object above while doing this in a loop, but you could maybe do this after

  #Remember that (using dplyr) PLAND can be calculated by n() = sum(n()) for each unique wetland-year combination








# What should this look like in the end?
load("capstone_projects/habitat/wetlands_landcover_loop_result.Rdata")
glimpse(wtld_all_lc)


### 4. Keep only the dominant (i.e. highest proportion) pland for each wetland_year ---------------------------------------
    #And turn this into a "wide" data frame where each row is a unique wetland-year combination

#HINT: some wetland-year combinations will have ties (i.e. more than one landcover type tied for highest proportion)
  #Choose only one; I did so based on which was the landcover type that was the top-ranked in other years for that wetland








# What should this look like in the end?
load("capstone_projects/habitat/wetlands_dominant_landcover.Rdata")
glimpse(wtld_pland)


### 5. Graph the results of either step 3 or step 4  ------------------------------------------------------------------------









# What should this look like in the end? No idea yet!!! :)





