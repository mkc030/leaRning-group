---
title: "Tidy lotr data"
output: 
  html_document:
    keep_md: TRUE
---



## Import data

```
## ── Attaching packages ───────────────────────────────────────────────────────────── tidyverse 1.3.0 ──
```

```
## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
## ✓ tibble  2.1.3     ✓ dplyr   0.8.3
## ✓ tidyr   1.0.2     ✓ stringr 1.4.0
## ✓ readr   1.3.1     ✓ forcats 0.4.0
```

```
## ── Conflicts ──────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```
## Parsed with column specification:
## cols(
##   Film = col_character(),
##   Race = col_character(),
##   Female = col_double(),
##   Male = col_double()
## )
## Parsed with column specification:
## cols(
##   Film = col_character(),
##   Race = col_character(),
##   Female = col_double(),
##   Male = col_double()
## )
## Parsed with column specification:
## cols(
##   Film = col_character(),
##   Race = col_character(),
##   Female = col_double(),
##   Male = col_double()
## )
```

## Untidy lotr data

```r
lotr_untidy <- bind_rows(fellow, tower, king)
str(lotr_untidy)
```

```
## Classes 'spec_tbl_df', 'tbl_df', 'tbl' and 'data.frame':	9 obs. of  4 variables:
##  $ Film  : chr  "The Fellowship Of The Ring" "The Fellowship Of The Ring" "The Fellowship Of The Ring" "The Two Towers" ...
##  $ Race  : chr  "Elf" "Hobbit" "Man" "Elf" ...
##  $ Female: num  1229 14 0 331 0 ...
##  $ Male  : num  971 3644 1995 513 2463 ...
```

## Tidy the untidy data
#### Use the old function - gather() 
This function is no longer recommended for use, but as there are many examples with it, let's use this to compare to the newer version of the same function.

Note here that adding the two variables at the end ('Female' and 'Male') specifies the two columns that are gathered together into two new columns. If you forget to add these, the function defaults to gathering the first two columns in the dataframe. Not helpful in this case!!! 

The first new column *(column name specified using* `key = `*)* is filled by the column names from the original dataset (eg "Female" and "Male" in this case). 

The second new column *(column name specified using* `value = `*)* is filled by the cell values contained within the two gathered columns (eg the numbers representing word count in this case).


```r
lotr_tidy <- gather(lotr_untidy,
                    key = "Gender",
                    value = "Words",
                    Female, Male)
```

#### Use the new tidyverse function - `pivot_longer()` 
This function replaces gather—*and conversly,* `pivot_wider()` *replaces* `spread()`. See `vignette("pivot")` for details, but in essence: 

* the first argument is the dataset, 
* the second argument is the columns to be reshaped, 
`names_to` gives the new column name containing values based on the old column names *(eg gender in our case)*, and 
* `values_to` gives the new column name for the old cell values *(eg word count in our case)*.

The advantage of the new pivot functions are that they can also be used with different datatypes being used as column names (eg dates, numeric data, many variables in one column name, etc), it can drop rows containing NAs in the old cell values, and allows for some additional data maninpulation directly within the pivot function. See vignette for more details. It is really good.

```r
lotr_pivtidy <- lotr_untidy %>% 
                    pivot_longer(cols = c("Female", "Male"),
                                 names_to = "Gender",
                                 values_to = "Words")
identical(lotr_pivtidy, lotr_tidy) #Hmmm this is false, but maybe just because of different order?
```

```
## [1] FALSE
```

```r
(d <- setdiff(lotr_pivtidy, lotr_tidy)) #Yes! Returns zero rows different in pivot tidy than tidy
```

```
## # A tibble: 0 x 4
## # … with 4 variables: Film <chr>, Race <chr>, Gender <chr>, Words <dbl>
```

```r
(d <- setdiff(lotr_tidy, lotr_pivtidy)) #Also zero rows different in tidy than in pivot tidy. Excellent!
```

```
## # A tibble: 0 x 4
## # … with 4 variables: Film <chr>, Race <chr>, Gender <chr>, Words <dbl>
```

## Practice exercises
Load and inspect untidy data

```r
male <- read_csv("data/Male.csv")
```

```
## Parsed with column specification:
## cols(
##   Gender = col_character(),
##   Film = col_character(),
##   Elf = col_double(),
##   Hobbit = col_double(),
##   Man = col_double()
## )
```

```r
female <- read_csv("data/Female.csv")
```

```
## Parsed with column specification:
## cols(
##   Gender = col_character(),
##   Film = col_character(),
##   Elf = col_double(),
##   Hobbit = col_double(),
##   Man = col_double()
## )
```

```r
glimpse(male)
```

```
## Observations: 3
## Variables: 5
## $ Gender <chr> "Male", "Male", "Male"
## $ Film   <chr> "The Fellowship Of The Ring", "The Two Towers", "The Return Of…
## $ Elf    <dbl> 971, 513, 510
## $ Hobbit <dbl> 3644, 2463, 2673
## $ Man    <dbl> 1995, 3589, 2459
```

```r
glimpse(female)
```

```
## Observations: 3
## Variables: 5
## $ Gender <chr> "Female", "Female", "Female"
## $ Film   <chr> "The Fellowship Of The Ring", "The Two Towers", "The Return Of…
## $ Elf    <dbl> 1229, 331, 183
## $ Hobbit <dbl> 14, 0, 2
## $ Man    <dbl> 0, 401, 268
```

Need to ensure the column names are identical for binding, then bind, then pivot data to make sure there is 1 row per word count.

```r
identical(names(male), names(female))
```

```
## [1] TRUE
```

```r
new_untidy <- bind_rows(male, female)
new_tidy <- new_untidy %>% 
              pivot_longer(cols = -c(Gender, Film),
                           names_to = "Race",
                           values_to = "Words")
```

Now calculate words spoken by race, using both seperate and new tidy datasets

##### Separate Dataframes

```r
(elves <- sum(male$Elf, female$Elf))
```

```
## [1] 3737
```

```r
(hobbits <- sum(male$Hobbit, female$Hobbit))
```

```
## [1] 8796
```

```r
(humans <- sum(male$Man, female$Man))
```

```
## [1] 8712
```
##### Single, Tidy Dataframe

```r
kable(new_tidy %>% 
          group_by(Race) %>% 
          summarize(words_spoken = sum(Words)))
```



Race      words_spoken
-------  -------------
Elf               3737
Hobbit            8796
Man               8712
