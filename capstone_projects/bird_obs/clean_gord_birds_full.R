#################################################################################################
##       CLEANING AND PREP of Gord's bird observations (prior to merging)                      ##
#################################################################################################

### Load packages
    library(stringi)
    library(tidyverse)
    library(lubridate)
    library(rebus)
    library(XLConnect)


########################################  
### 1. Import the excel datasheet     ##
########################################

### Import Environmetal data for the sediment samples using readr package
    #To prevent read_csv importing 'time' as a time period, rather than a date-time object, need to use read.csv instead
      #And need to do this on BOTH or else it imports the column names differently for the crosses...as read.csv replaces all '/' seperators with '.'
    Gord.yr1 <- read.csv("Data/Working Raw Data/Phase2_Bird Counts_data sheet August 18, 2017_forR_csv.csv",
                         stringsAsFactors = F)
      #Note that Gord updated the Yr1 sheet once we realized the count for Aug 18, 2017 was missing
        #I double checked in R, and apart from that one week, the two datasheets are identical

    Gord.yr2 <- read.csv("Data/Working Raw Data/Phase2_Bird Counts_data sheet YEAR 2 August 25, 2018_forR_csv.csv",
                         stringsAsFactors = F)
  # Remove extra empty columns - don't need if using read.csv
    #Gord.yr1 <- Gord.yr1[-c(242:248)]
    #Gord.yr2 <- Gord.yr2[-c(242:248)]
    
  # Remove empty rows at end of Yr1 data 
    empty <- which(Gord.yr1$date == "")
    Gord.yr1 <- Gord.yr1[-empty, ]  
    
### Ensure has imported properly - to remove eventually
  # yr 1
    glimpse(Gord.yr1)
    head(Gord.yr1)
    tail(Gord.yr1, n = 10)

  # Repeat with yr2
    glimpse(Gord.yr2)
    head(Gord.yr2)
    tail(Gord.yr2)
    
### Any NAs?
    colSums(is.na(Gord.yr1))
      #Yes, will remove below using not.time object
    colSums(is.na(Gord.yr2))
      #no
    
### However, on May 6, 2017 for JAC there are counts that have zeros but should actually be 'NA' b/c the park was closed
    #Gord confirmed that he did not enter JAC on the date of "Park closed due to dog training"
    
  # To view all notes on dog-related days  
     dog1 <- which(str_detect(Gord.yr1$notes, pattern = rebus.base::or("dog", "Dog")))
     dog2 <- which(str_detect(Gord.yr2$notes, pattern = rebus.base::or("dog", "Dog")))
     yr1.dogs <- Gord.yr1[dog1, c(1:3, 242)]
     yr2.dogs <- Gord.yr2[dog2, c(1:3, 242)]
     # Only one date where park was closed during Year 1, will remove this below with 'park.closed'
     
  # Clean up workspace
    rm(empty, dog1, dog2, yr1.dogs, yr2.dogs)
    
    
#######################################################  
###       2. Clean data for merging together        ###
#######################################################
### Remove the observations for May 6, 2017 when JAC was closed - as it was actually not a zero count but a non-count
    park.closed <- which(str_detect(Gord.yr1$notes, pattern = fixed("Park closed")))
    Gord.yr1 <- Gord.yr1[-park.closed, ]
    
### Remove the row with "no count" for Nov 18, 2016 from JAC (at index 44) or time does not parse properly!
    not.time <- which(Gord.yr1$time == "No count")
    Gord.yr1 <- Gord.yr1[-not.time, ]
    
    
### Change classes of columns 
  # 'time' to hours and minutes
################ I need to fix this as this turns time into a PERIOD in seconds instead of a time stamp.... ################  
    #Gord.yr1$time <- parse_time(Gord.yr1$time, format = "%H:%M")
    #Gord.yr2$time <- parse_time(Gord.yr2$time, format = "%H:%M")
    
  # 'date' to month day, year
    #Gord.yr1$date <- parse_date(Gord.yr1$date, format = "%B %d, %Y")
    #Gord.yr2$date <- parse_date(Gord.yr2$date, format = "%B %d, %Y")
    
### hmm, just deal with in a later script for now....  ###  
    
  rm(not.time, park.closed)
  
### Change to tibbles to make it easier to look at/wrangle data
  Gord.yr1 <- as.tibble(Gord.yr1)
  Gord.yr2 <- as.tibble(Gord.yr2)  
  
#######################################################  
###    3. Merge both years of data together         ###
#######################################################    
    
### Bind the two years of data together into one dataframe (columns are identical!)
    Gord.all <- bind_rows(Gord.yr1, Gord.yr2)
    
    rm(Gord.yr1, Gord.yr2)
    
    
##################################################################### 
###    4. Clean columns so it's an easier format to analyze       ###
#####################################################################  
 
### Turn the 'date' column into actual dates
    Gord.all$date <- dmy(Gord.all$date)
    
### Turn 'wtld' into a factor for easier graphing
    Gord.all$wtld <- str_trim(Gord.all$wtld)  
  # Should remove LMT observations; do before grouping or else the df will continue to have group for LMT with 0 observations
    Gord.all <- Gord.all[Gord.all$wtld != "LMT", ]
    Gord.all$wtld <- as.factor(Gord.all$wtld)
    
### Seperate out each "count" column (i.e. # of birds, # of red bands, etc) FIRST then merge them based on species and date 
    #to prevent multiplication of data by 34 species again each time 'gather' is used
################## SHould really write this as a function!!!! ##########################    
    colors <- c("red", "green", "yellow", "blue", "unkn")
    colors = "red"
    
  # Make a function that seperates out band colors
    ### THIS DOES NOT WORK...need to try to figure this out again later...
    sep.bands.col <- function(data, i) {
                          Gord.i <- select(data, date,
                                                wtld,
                                                time,
                                                ends_with("i"),
                                                notes)
                          return(Gord.i)
                          print(i)
    } 
#########################################################################################
### TODO turn this into a function! Have part of the loop ready to go in 'func AIV matrix' script at the moment...    
  # Red band counts
    Gord.red <- select(Gord.all, date,
                                   wtld,
                                   time,
                                   ends_with("red"),
                                   notes)
    
    # Make one column for species and one column for number of red bands counted
      Gord.red <- gather(Gord.red, key = "species", value = "n_red_band", ends_with("red"))
    # Remove the band colour from the species name so can use it as a key for merging
      Gord.red$species <- str_remove_all(Gord.red$species, pattern = "_red")
    
  # Green band counts
    Gord.green <- select(Gord.all, date,
                       wtld,
                       time,
                       ends_with("green"),
                       notes)
    # Make one column for species and one column for number of green bands counted
      Gord.green <- gather(Gord.green, key = "species", value = "n_green_band", ends_with("green"))
    # Remove the band colour from the species name so can use it as a key for merging
      Gord.green$species <- str_remove_all(Gord.green$species, pattern = "_green")
    
  # Yellow band counts
    Gord.yel <- select(Gord.all, date,
                         wtld,
                         time,
                         ends_with("yellow"),
                         notes)
    # Make one column for species and one column for number of green bands counted
      Gord.yel <- gather(Gord.yel, key = "species", value = "n_yellow_band", ends_with("yellow"))
    # Remove the band colour from the species name so can use it as a key for merging
      Gord.yel$species <- str_remove_all(Gord.yel$species, pattern = "_yellow")
    
  # Blue band counts - which should actually be 'white'...
    Gord.blue <- select(Gord.all, date,
                       wtld,
                       time,
                       ends_with("blue"),
                       notes)
    # Make one column for species and one column for number of green bands counted
      Gord.blue <- gather(Gord.blue, key = "species", value = "n_blue_band", ends_with("blue"))
    # Remove the band colour from the species name so can use it as a key for merging
      Gord.blue$species <- str_remove_all(Gord.blue$species, pattern = "_blue")
    
  # Unknown color band counts 
    Gord.unkn <- select(Gord.all, date,
                        wtld,
                        time,
                        ends_with("unkn"),
                        notes)
    # Make one column for species and one column for number of green bands counted
      Gord.unkn <- gather(Gord.unkn, key = "species", value = "n_unkn_band", ends_with("unkn"))
    # Remove the band colour from the species name so can use it as a key for merging
      Gord.unkn$species <- str_remove_all(Gord.unkn$species, pattern = "_unkn")
      
  # Will NOT do for the "none" (i.e. no band) column, as it is the same as the bird abundance count, so would just be duplicating the abundance column
    
### Make one column for species and one for count, instead a seperate column for each species
    Gord.count <- gather(Gord.all, key = "species", value = "count", 
                   gwfgoo, snogoo, brant, cackgoo, cangoo, 
                   mutswa, truswa, tunswa, wooduc, gadwall,
                   eurwig, amwiXeuwi, amewig, mallard, buwtea,
                   cintea, norsho, norpin, gnwtea, canvas,
                   redhead, rinduc, grscXrndu, gresca, lessca,
                   sursco, whwsco, buffle, comgol, bargol,
                   hoomer, commer, rebmer, rudduc)

  # Remove the band count columnns from the data with the bird abundance counts
    Gord.count <- select(Gord.count, date, wtld, time, species, count, notes)
    rm(Gord.all)
    
### Bind together all the datasets using date, wetland, time, species, and notes as merging keys
    Gord.birds <- full_join(Gord.count, Gord.red, by = c("date", "wtld", "time", "notes", "species"))
    #Repeat with all other band colors
    Gord.birds <- full_join(Gord.birds, Gord.green, by = c("date", "wtld", "time", "notes", "species"))
    Gord.birds <- full_join(Gord.birds, Gord.yel, by = c("date", "wtld", "time", "notes", "species")) 
    Gord.birds <- full_join(Gord.birds, Gord.blue, by = c("date", "wtld", "time", "notes", "species"))
    Gord.birds <- full_join(Gord.birds, Gord.unkn, by = c("date", "wtld", "time", "notes", "species"))
    
    rm(Gord.count, Gord.red, Gord.green, Gord.yel, Gord.blue, Gord.unkn)
    
#### TODO - (i) Group all the leg band color counts as well  - need to do with with LOOPS and FUNCTIONS!!!!; 
             #(ii) ditto with the Merging columns together...I bet I can do this with purrr!!
                    #I can't make either work....
    

    #(iii) Make a 'TOTAL' value in the species column that sum all abundance for each date at each wetland)...or should this be a seperate column on it's own??
    Gord.birds <- Gord.birds %>% group_by(date, wtld) %>% mutate(total_ab = sum(count))        
    
    #(iv) Add a new column with diversity (for each date at each wetland)
    Gord.birds <- Gord.birds %>%
                      group_by(date, wtld) %>%
                      mutate(total_sp = sum(count >= 1))
    
    # Ungroup to remove the annoying grouping structure now that we've made the relevant columns...
    str(Gord.birds)
    Gord.birds <- ungroup(Gord.birds)
  
    # TODO (v) Try to make a Shannon diversity index using 'vegan' package
    library(vegan)
    #I'm not really sure what format (or what type of) the data needs to be in, so let's try to vignette for starters
    browseVignettes("vegan")

    #(vi) Recall that don't have the full access to JAC until ?Oct 2016? (notes say "First time counting whole site from public access") 
      #Should I remove observations from JAC prior to then so are comparing apples to apples?; although also were not trapping the whole site at that time, so observations are concordent with trapping...
    
    #(viii) Use an 'add.monyr' function to add the month-year column to the df for merging/graphing later...I can't make this work so will do the copy and paste method for now
    Gord.birds$mon <- month(Gord.birds$date, label = T, abbr = T)
    Gord.birds$yr <- year(Gord.birds$date)
    Gord.birds$mon_yr <- paste(Gord.birds$mon, Gord.birds$yr, sep = "-")
    Gord.birds$mon_yr <- factor(Gord.birds$mon_yr, levels = c("Aug-2016", 
                                                              "Sep-2016", "Oct-2016", "Nov-2016", "Dec-2016",
                                                              "Jan-2017", "Feb-2017", "Mar-2017", "Apr-2017",
                                                              "May-2017", "Jun-2017", "Jul-2017", "Aug-2017",
                                                              "Sep-2017", "Oct-2017", "Nov-2017", "Dec-2017",
                                                              "Jan-2018", "Feb-2018", "Mar-2018", "Apr-2018",
                                                              "May-2018", "Jun-2018", "Jul-2018", "Aug-2018"))
  
    

    save(Gord.birds, file = "Practice/Gord tidy.rdata")

    