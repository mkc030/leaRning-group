Bird habitat and landcover: capstone project outline
================
Michelle Coombe
2020-05-15

I think this is probably the easier of the capstone projects, so might
be best to start with this one vs. the bird observation one. However,
you may disagree\!

## Background of data

One of my current thesis questions is how to prioritize environmental
sampling protocols for avian influenza surveillance. To do this, I am
trying to understand what factors are associated with a sampling site
higher odds of having an avian influenza-positive sampling site. One
such possible variable is ‘bird habitat’, as wild waterfowl birds may be
more likely to spend time at a sampling site (and thus deposit avian
influenza virus (AIV)) based on habitat type. Similarly, the type of
land usage (e.g. urban vs. agriculture) and plant assemblages can affect
the soil composition, which can in turn affect how quickly a virus
degrades and also how easily it can be extracted from a sample.
Therefore I am using satalite-derived landcover measures as an indicator
of the ‘bird habitat’ and ‘land use’ of a particular wetland.

This landcover data has been extracted from several raster (image) files
downloaded from NASA’s MODIS tool. I am using the layer with the
University of Maryland landcover classification system (see below for
more details) with 16 possible landcover types. Each wetland has
multiple values for landcover, and I want to determine the PLAND
(Proportion of LANDcover) for each of wetland, per calendar year (2016,
2017, 2018). All the information is currently stored in a list, but
needs to be in a data frame in order to be used for statistical analysis
or for plotting.

I should also give a big shout out to the ‘eBird best practices’ online
[book](https://cornelllabofornithology.github.io/ebird-best-practices/)
as I based most of my code in this script off of their site. The coding
can be a little hard to follow sometimes but it’s reasonably well
commented and it has the best description I could find of actually
trying to download and do a spatial-merge using MODIS data with a
buffer.

## Capstone project goals

Write a function that does the following (could be done either together
or seperately):

1.  Determine the PLAND (Proportion of LANDcover) for of each of the 16
    landcover types, per wetland, per calendar year.

2.  Rename landcover types based on something more meaningful (see the
    lc\_names object in the code). I think this probably isn’t a
    necessary step or could be done after doing step 3.

3.  Extract the landcover values out of the list and turn into a data
    frame

Bonus goals:

4.  Determine the dominant landcover type per wetland-year. Turn this
    into a “wide” dataframe (type `?pivot_wider` or `vignette("pivot")`
    into the console to see examples) with one row for each unique
    wetland-year combination. *Why bother? I needed to do this in order
    to join to my full wetland dataset, which has one row for unique
    combination of sample site and date.*

5.  Make a plot to display landcover types for each wetland (the results
    of either goals 1/2/3 or 4). I have not done this yet, but will need
    to for data exploration. *I suspect this will involve reshaping the
    data again with* `pivot_longer` *and multiple individual plots per
    wetland could be made using* `purrr::walk`*.*

## Overview of files

The starting point for working on this problem is in the
[import\_habitat\_start](capstone_projects/habitat/import_habitat_start.R)
script. This contains the data, the packages you will need, and some
headers for steps.

There is a hints
[file](capstone_projects/habitat/import_habitat_hints.R) that contains
some of the code I used in my loops, in case you want to have some
working snipets of code to jump into the actually making a function
part, without having to figure out how to wrangle the data. I’ve also
included some code about how I usually figure out how to write a loop,
and I assume the same approach would work for trying to write a function
(although I can’t write functions so…maybe not???).

My current solution to goals 1 to 4 (and the whole download process if
you are interested) is in the
[import\_habitat\_full](capstone_projects/habitat/import_habitat_full.R)
file.

There is a dataset to import and use for function writing, but then also
a dataset of what you want as an output. You can load all these files
from the
[import\_habitat\_start](capstone_projects/habitat/import_habitat_start.R)
script.

## More detailed overview of data

PLAND is calculated as: (count of values for that landcover type for one
wetland-year) / (total count of values for ALL landcover types for one
wetland-year). Or in dplyr terms, you can think of it as: PLAND = n() /
sum(n())

There are 21 wetlands included in this dataset: JAC, LAX, WBC, BHER,
BRY, BURN, LMT, MIL, MNP, NIC, PIT, REI, SAR, SDW, SFEN, SIS, STA, TRL,
TUY, TWU, and WCK.

There are 3 calendar years included in this dataset (2016, 2017, 2018).
As the MODIS data is updated yearly, I wanted to use the appropriate
landclass/PLAND values for the calander year in question. You will
notice though that there isn’t a lot of difference in landcover types
between different years\! Which makes sense.

The University of Maryland classification system uses 16 possible
landcover types:

  - Layer 0 = water

  - Layer 1 = evergreen\_needleleaf

  - Layer 2 = evergreen\_broadleaf

  - Layer 3 = deciduous\_needleleaf

  - Layer 4 = deciduous\_broadleaf

  - Layer 5 = mixed\_forest

  - Layer 6 = closed\_shrubland

  - Layer 7 = open\_shrubland

  - Layer 8 = woody\_savanna

  - Layer 9 = savanna

  - Layer 10 = grassland

  - Layer 11 = wetland

  - Layer 12 = cropland

  - Layer 13 = urban

  - Layer 14 = mosiac

  - Layer 15 =
barren

#### Sidenote - why on earth are there multiple landclass values for each wetland? And why are there different number landcover values for different wetlands?

This is primarily because birds will be using habitat beyond that just
within the wetland (…they do fly lol\!). The Cornell Lab of Ornithology
recommends using a buffer of 2.5km around a bird observation to
adequately represent the habitat a bird would typically be using. Their
example was with songbirds and we are dealing with waterfowl, so maybe
even a larger buffer would be better, but it was the best estimate I
could find, so I’m sticking with it for now. Secondly, although we were
sampling in water, I don’t actually want the “water” classification to
be included as a possible land type in my model, as it is not very
helpful when it comes to interpreting the model. (Where should we go to
find avian flu? Wetlands that have water = useless; but much more
helpful to say wetland that have a lot of urban land use or wetlands
that have a lot of decideous broadleaf plants.)

So to deal with this, I made a 2.5km buffer around the midpoint of each
wetland, and then extracted all the raster cells that were within the
2.5km radius. 1 raster cell = 1 set of values for each of the 16
landcover layers. However, as each wetland midpoint does not fall in the
same place within a raster cell, there will be different number of cells
(and thus values for landclasses) for each wetland. For a visual image
of what I mean see [this
image](https://datacarpentry.org/r-raster-vector-geospatial/images/BufferCircular.png)
from the data carpentry
[website](https://datacarpentry.org/r-raster-vector-geospatial/11-vector-raster-integration/index.html).
