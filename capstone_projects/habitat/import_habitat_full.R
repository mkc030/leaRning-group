#################################################################################################
###                                                                                           ###
###                      Download land_use covariate from MODIS                               ###
###   From MODIS MCD12Q1 v006, using University of Maryland (UMD) land cover classification   ###
###                                                                                           ###
###      The "Best Practices for Using eBird Data" ebook was very useful for this code        ###
###  available at: https://cornelllabofornithology.github.io/ebird-best-practices/index.html  ###
###                                                                                           ###
#################################################################################################
#TODO: Add the import habitat and import ebird parts of those scripts together into one...DO I REALLY WANT TO DO THIS???
#TODO: Change Sed.final dataset location to Ext.sed WITHIN THIS PROJECT once run - in import scripts and in wtld_locations script
#TODO: Figure out if still need the wetland locations script as a seperate thing, or if can delete from this project

### 1. Load packages-------------------------------------------------------------------------------------------------------------
library(sf) 
library(raster)
library(tidyverse) #Note dplyr masks 'raster' extract() and select() functions

### Install and load luna, a package with satalite remote sensing functions
# Only need to do once
#   library(remotes)
#   remotes::install_github("rspatial/luna")
#library(terra) #Note terra masks dplyr's collapse() function
library(luna)


### 2. Determine the boundary (+ ~10km for wiggle room) for the AIV Phase 2 Study Area  ----------------------------------------
  # This is the same as the boundary with wiggle room used for the ebird data download

# Load Sediment dataset to determine the spatial extent in UTM
#TODO: Change to dataset WITHIN THIS directory
load("/Users/Michelle 1/Documents/R projects/AIV PhD/Data/Cleaned Data/Merged sediment cleaned data.rdata") # Sed.final

# Summarize current UTM (using the same order as in auk_bbox documentation)
Sed.final %>% 
  summarize(min_x_east = min(east),
            min_y_north = min(north),
            max_x_east = max(east),
            max_y_north = max(north))

# Make an object from current UTM plus a 10km buffer in all directions
  #Buffer is so that we have data if/when we need to aggregate values around edge of sampling points
utm_10km <- data.frame(x = c(485376, 592475),
                       y = c(5427716, 5467163))

# Turn into spatial points
  # Phase 2 measured location using WGS84 (in metric units) / and the UTM zone is 10N whose's EPSG code is: 32610
  # if I look it up, the equivalent proj4strings is: +proj=utm +zone=10 +ellps=WGS84 +datum=WGS84 +units=m +no_defs
sp_10km <- SpatialPoints(utm_10km[, c("x", "y")],
                         proj4string=CRS("+proj=utm +zone=10 +datum=WGS84"))

# Now transform the coordinate system to EPSG 4326 
  # This is the default for MODIS bounding boxes (see ?getTile from MODIS)
  # This is also the coordinate system for lat/long, which is NOT projected 
t_10km <- spTransform(sp_10km, CRS("+init=epsg:4326"))
t_10km@bbox

rm(utm_10km, sp_10km)


### 3. Set up to download MODIS data for MCD12Q1 product with luna -------------------------------------------------------------

# List available tiles using luna, for our date and area boundaries
habitat.tiles <- getModis(product = "MCD12Q1",
                          version = "006",
                          start_date = "2016-01-01",
                          end_date = "2018-12-31",
                          aoi = t_10km,
                          download = F,  #This part is key to only listing the tiles!!! 
                          path = tempdir())
habitat.tiles
    #Excellent!!!


### 4. Download MODIS landcover variables using 'luna' package  -----------------------------------------------------------------
# Set path for downloads, MUST be under username WITHOUT spaces or the conversion program won't work
mypath = "/Users/Michelle/modis_hdfs"

# Enter username and password for Earthdata ***CANNOT DISPLAY THIS PUBLICALLY, so need to type in manually***
ed <- as.list(c("usr" = "",  # NEED TO FILL THIS IN MANUALLY
                "pw" = ""))   # NEED TO FILL THIS IN MANUALLY

# Run only if files don't already exist
hdf_file <- file.path("/Users/Michelle/modis_hdfs",
                      "MCD12Q1.A2018001.h10v04.006.2019199224423.hdf") #Name of the final hdf file


if (!file.exists(hdf_file)) {
modis.files <- getModis(product = "MCD12Q1",
                          version = "006",
                          start_date = "2016-01-01",
                          end_date = "2018-12-31",
                          aoi = t_10km,
                          username = ed$usr,  #Must enter your EarthData username
                          password = ed$pw,   #Must enter your EarthData 
                          download = T,  #Setting this to 'T' is key to downloading the files!! 
                          path = mypath)
}

rm(habitat.tiles, mypath, ed, hdf_file, modis.files, t_10km)

### 6. Convert hdf4 files to one raster (.tif) per layer for the study area, per year  ------------------------------------------
#  Use Ian's fancy script by:
# - moving the script convert_hdf_old.sh AND the downloaded MODIS files into seperate folders per year
#   under the 'Michelle' directory under Users
# - note that this will NOT work if the files are under the Michelle 1 folder as the
#   spaces mess everything up
# - and that if the files must be seperated by year or they convert_hdf.sh will overwrite with the same names
# - running the script in the terminal by using the command ./convert_hdf_old.sh
# - this script will now merge all the MODIS location tiles covering the study area into one
#   but you still end up with one .tif per layer, per year (these are now named _merged.tif)
# - I have manually moved these files to the local MODIS folder (ignored by Git) so I know I have local copies
# - I have also manually renamed to incorporate the year of collection in the names

# In theory, may be able to do this using the 'terra' package, but doesn't seem to recognize .hdf files for me
# h09.2016 <- rast("/Users/Michelle 1/Documents/R projects/phd-environ-matrix/MODIS/luna_modis/2016/MCD12Q1.A2016001.h09v04.006.2018149124910.hdf")

# Another option may be to call gdal_translate to turn the .hdf into one .tif per layer
# This is the function the 'convert_hdf_old.sh' uses; however, not entirely sure how to run it in R
# But probably could figure it out eventually...

### 7. Load the landcover data   ------------------------------------------------------------------------------------------------
  # Apparently there are only 13 layers (per hdf tile) in this product
  # And the layer we are interested in is layer #2 
  # which is the University of Maryland ('UMD') landcover classification
  # see https://lpdaac.usgs.gov/products/mcd12q1v006/ for the documentation
  # The last layer (#13) may also be useful at some point, as it is a binary water vs. no water mask

# Load layer 2 from each year as a Raster Layer, merge by year, and plot to make sure looks ok
  #Sadly it looks like the merged tifs did NOT merge properly using Ian's convert file
  #so I will load the tifs for h09 and h10 tiles for layer #2 seperately and merge in R

# 2016
r2016.09 <- raster("MODIS/luna_modis/2016/MCD12Q1.A2016001.h09v04.006.2018149124910_02.tif")
r2016.10 <- raster("MODIS/luna_modis/2016/MCD12Q1.A2016001.h10v04.006.2018149124953_02.tif")
m2016 <- raster::merge(r2016.09, r2016.10)
plot(m2016, main = "2016 raster layer")

# 2017
r2017.09 <- raster("MODIS/luna_modis/2017/MCD12Q1.A2017001.h09v04.006.2019196133753_02.tif")
r2017.10 <- raster("MODIS/luna_modis/2017/MCD12Q1.A2017001.h10v04.006.2019196133849_02.tif")
m2017 <- raster::merge(r2017.09, r2017.10)
plot(m2017, main = "2017 raster layer")

# 2018
r2018.09 <- raster("MODIS/luna_modis/2018/MCD12Q1.A2018001.h09v04.006.2019199221255_02.tif")
r2018.10 <- raster("MODIS/luna_modis/2018/MCD12Q1.A2018001.h10v04.006.2019199224423_02.tif")
m2018 <- raster::merge(r2018.09, r2018.10)
# plot(r2018.09)
# plot(r2018.10)
plot(m2018, main = "2018 raster layer") #Looks WAY better

# Rename layer names to indicate the year of data collection
names(m2016) <- "y2016"
names(m2017) <- "y2017"
names(m2018) <- "y2018"

# Combine into a raster stack with layers by year
landcover <- raster::stack(m2016, m2017, m2018)

# Clean up workspace
rm(r2016.09, r2016.10, m2016, r2017.09, r2017.10, m2017, r2018.09, r2018.10, m2018)


### 8. Extract raster values in a 2.5km radius, based on center of each wetland   ---------------------------------------------
  #2.5km x 2.5km is ~5 MODIS cells and is recommended based on "eBird best practices" ebook
  #because it provides sufficient spatial resolution in the data while still being relevant 
  #to the biology of most birds

# Set up neighbourhood radius equal to 5 MODIS cells
neighbourhood_radius <- 5 *ceiling(max(res(landcover))) / 2

# Determine the mid-point of the sampling area in each wetland 
  #and ensure 5 MODIS cells (ie ~2.5km radius) would be adequate to represent the whole sampling area 
  #I will used the easting and northings and let spatial transformations ensure it is in the same CRS
  #as the raster and/or eBird data
wtld_sizes <- Sed.final %>% 
                group_by(wtld) %>% 
                summarize(min_x_east = min(east),
                          max_x_east = max(east),
                          middle_east = min(east) + ((max(east) - min(east)) / 2),
                          min_y_north = min(north),
                          max_y_north = max(north),
                          middle_north = min(north) + ((max(north) - min(north)) / 2),
                          size_km_x = (max(east) - min(east))/ 1000,  
                          size_km_y = (max(north) - min(north))/ 1000)

range(wtld_sizes$size_km_x)
range(wtld_sizes$size_km_y)
  #The range of distances for observations within a wetland is less than 1km for all wetlands
  #eBird best practices suggests that-for habitat covar-a 2.5km *2.5km distance around each 
  #ebird checklist is a sufficient distance to account for, so seems logical that a similar buffer 
  #would also still be relevant for birds that might be depositing feces in our samples 

# Make a buffer zone around the midpoint of each wetland and turn into a spatial (sf) object
  #For sediment dataset, we measured WGS84 (in metric units) / and the UTM zone is 10N whose's EPSG code is: 32610
  #if I look it up, the equivalent proj4strings is: +proj=utm +zone=10 +ellps=WGS84 +datum=WGS84 +units=m +no_defs

wtld_buf <- wtld_sizes %>% 
              dplyr::select(wtld, middle_east, middle_north) %>% 
              #Convert to spatial feature
              st_as_sf(coords = c("middle_east", "middle_north"), crs = "+proj=utm +zone=10 +datum=WGS84") %>% 
              #Transform to same projection as raster
              st_transform(crs = projection(landcover)) 

wtld_lc <- raster::extract(x = landcover, 
                              y = as(wtld_buf, "Spatial"),
                              nl = 3,
                              buffer = neighbourhood_radius, #Buffer around midpoint of sampling locations for each wetland
                              small = T) #Returns a value even no cell center is within the buffer zone

# Name each list based on the order of the wetlands in wtld_buf
  #note that raster::extract does not name the returned values, but help file
  #says the returned values correspond to the order of object 'y' (i.e. wtld_buf in this case)
names(wtld_lc) <- wtld_buf$wtld
wtld_lc[1] #Worked


### 9. From this list, extract a count of occurances and PLAND of each landclass, by wetland, by year ----------------------------
  #PLAND values = Porportion of LANDscape in each land cover class from UMD classification system

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

#Because wtld_lc is a list of list, I need to do some weird coding to extract the values into rows
  #There must be a simplier way to do this, but I can't figure it out, so have done this for the moment...
  #This WILL throw some warnings re: coersion to characters, it's fine to just ignore them

# Make an empty list for dataframes of each wetland
spatial_list = list()

# Make an empty list for frequency counts and pland values for each wetland_year combo
pland_list = list()

#Loop through each element (wetland) in wtld_lc to make a data frame
  #Making a data frame is necessary or else dplyr::count won't work
for(i in 1:length(wtld_lc)) {
  w <- as.data.frame(wtld_lc[i])

  #Loop through each year (i.e. column) within the data frame in the list of wetlands
  for(j in 1:ncol(w)){
    
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
    
    print(names(w)[j])
    #print(t1)
  }

# Turn the list into a dataframe
spatial_list[[i]] <- bind_rows(pland_list)

print(names(wtld_lc)[i])
}

# Now turn the spatial list into one data frame
wtld_all_lc <- bind_rows(spatial_list)


# Clean up workspace
rm(w, w.values, i, j, wtld_yr,
   pland_list, spatial_list, lc_names, wtld_lc, wtld_buf, neighbourhood_radius)



### 10. Keep only the dominant (i.e. highest proportion) pland for each wetland_year, excluding 00_water   ---------------------
  # Exclude water as this is not an informative landcover classification for selecting wetland sites
  # We are looking for which type of landcover might help us select specific wetlands for AIV sampling
  # And saying to go to the wetlands with water is not very helpful!
  # However, do not need to actively exclude water as 
  # no wetland site has this as their highest ranked pland landcover class

wtld_pland <- wtld_all_lc %>% 
                group_by(wtld_yr) %>% 
                filter(min_rank(desc(pland)) == 1) %>% 
                ungroup()
        
# Determine which wetland_year combinations have ties for first-place rank in PLAND
n.pland <- fct_count(wtld_pland$wtld_yr)
n.pland[which(n.pland$n > 1), ] #There are two wetlands_years with a tie (BHER.y2017 and LAX.y2016)
wtld_pland[grep(x = wtld_pland$wtld_yr, pattern = "BHER"), ]
wtld_pland[grep(x = wtld_pland$wtld_yr, pattern = "LAX"), ]

# For the tied wetland_year PLANDs, keep the landcover class that is top-ranking the other years for that wetland
#LAX
LAX.different <- which(wtld_pland$wtld_yr == "LAX.y2016" & wtld_pland$landcover == 14)
wtld_pland <- wtld_pland[-LAX.different, ]

#BHER
BHER.different <- which(wtld_pland$wtld_yr == "BHER.y2017" & wtld_pland$landcover == 10)
wtld_pland <- wtld_pland[-BHER.different, ]

# Some data cleaning to make merge later easier
#Separate wtld_yr column into two columns so can join to sediment dataset later
wtld_pland <- separate(wtld_pland, 
                       col = wtld_yr,
                       into = c("wtld", "year"),
                       sep = "\\.") #Dot needs to be in escaped or will function will fail

#Remove the 'y' from year 
wtld_pland$year <- str_replace(wtld_pland$year, pattern = "y", replacement = "")


# Clean up workspace
rm(n.pland, LAX.different, BHER.different)


### 11. Save as .csv files  ----------------------------------------------------------------------------------------------------
# Wetlands with mid-points of locations and all PLAND values, but need to do some data cleaning and reshaping first
wtld_all_lc<- separate(wtld_all_lc, col = wtld_yr,into = c("wtld", "year"),sep = "\\.") 
wtld_all_lc$year <- str_replace(wtld_all_lc$year, pattern = "y", replacement = "")

wtld_midpoints <- dplyr::select(wtld_sizes, c("wtld", "middle_east", "middle_north"))
wtld_all_lc <- full_join(wtld_all_lc, wtld_midpoints, by = "wtld")

wtld_all_lc <- wtld_all_lc %>% 
                    dplyr::select(-c("n", "landcover")) %>% 
                    pivot_wider(names_from = lc_name, values_from = pland)

write_csv(wtld_all_lc, "Data/Clean-data/wetlands_all_landcover_frequency_and_pland_values.csv")


# Wetlands with only the most common PLAND (don't need the 'n' now that have calculated PLAND)
wtld_dpland <- dplyr::select(wtld_pland, -n) 
write_csv(wtld_dpland, "Data/Clean-data/wetlands_dominant_pland.csv")


#Clean up workspace
rm(landcover, Sed.final, wtld_midpoints, wtld_sizes)
rm(wtld_all_lc, wtld_pland)


