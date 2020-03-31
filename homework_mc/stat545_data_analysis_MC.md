Notes on Data Analysis chapters from stat545.com
================
Michelle Coombe

# Overview of document

This doc is Michelle’s notes on useful tips and tricks gleaned the ‘Data
Analysis’ section of Jenny Bryan’s stat545 website. [go to
stat545](https://stat545.com/basic-data-care.html)

## Chapters 5 to 8 - Intro to dplyr

I have skimmed over and ignored most of the intro stuff, but the most
useful section I found was on tidying the LOTR datasets using the older
`gather` and `spread` functions and the newer `pivot` functions.

### Shortcuts

Typing a command in parentheses will automatically print the
object/command to the console.

Assignment operator (think “gets” when you see the arrow) for mac is:
option + dash

Pipe operator (think “then” when you see the symbol) for mac is: command
+ shift +
    m

### Import data and packages

    ## ── Attaching packages ──────────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.3.0     ✓ purrr   0.3.3
    ## ✓ tibble  2.1.3     ✓ dplyr   0.8.5
    ## ✓ tidyr   1.0.2     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.5.0

    ## ── Conflicts ─────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

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

### Untidy lotr data

``` r
lotr_untidy <- bind_rows(fellow, tower, king)
str(lotr_untidy)
```

    ## Classes 'spec_tbl_df', 'tbl_df', 'tbl' and 'data.frame': 9 obs. of  4 variables:
    ##  $ Film  : chr  "The Fellowship Of The Ring" "The Fellowship Of The Ring" "The Fellowship Of The Ring" "The Two Towers" ...
    ##  $ Race  : chr  "Elf" "Hobbit" "Man" "Elf" ...
    ##  $ Female: num  1229 14 0 331 0 ...
    ##  $ Male  : num  971 3644 1995 513 2463 ...

### Tidy the untidy data

#### Use the old function - gather()

This function is no longer recommended for use, but as there are many
examples with it, let’s use this to compare to the newer version of the
same function.

Note here that adding the two variables at the end (‘Female’ and ‘Male’)
specifies the two columns that are gathered together into two new
columns. If you forget to add these, the function defaults to gathering
the first two columns in the dataframe. Not helpful in this case\!\!\!

The first new column **(column name specified using** `key =`**)** is
filled by the column names from the original dataset (eg “Female” and
“Male” in this case).

The second new column **(column name specified using** `value =`**)** is
filled by the cell values contained within the two gathered columns (eg
the numbers representing word count in this case).

``` r
lotr_tidy <- gather(lotr_untidy,
                    key = "Gender",
                    value = "Words",
                    Female, Male)
```

#### Use the new tidyverse function - `pivot_longer()`

This function replaces gather—**and conversly,** `pivot_wider()`
**replaces** `spread()`. See `vignette("pivot")` for details, but in
essence:

  - the first argument is the dataset,
  - the second argument is the columns to be reshaped, `names_to` gives
    the new column name containing values based on the old column names
    **(eg gender in our case)**, and
  - `values_to` gives the new column name for the old cell values **(eg
    word count in our case)**.

The advantage of the new pivot functions are that they can also be used
with different datatypes being used as column names (eg dates, numeric
data, many variables in one column name, etc), it can drop rows
containing NAs in the old cell values, and allows for some additional
data maninpulation directly within the pivot function. See vignette for
more details. It is really good.

``` r
lotr_pivtidy <- lotr_untidy %>% 
                    pivot_longer(cols = c("Female", "Male"),
                                 names_to = "Gender",
                                 values_to = "Words")
identical(lotr_pivtidy, lotr_tidy) #Hmmm this is false, but maybe just because of different order?
```

    ## [1] FALSE

``` r
(d <- setdiff(lotr_pivtidy, lotr_tidy)) #Yes! Returns zero rows different in pivot tidy than tidy
```

    ## # A tibble: 0 x 4
    ## # … with 4 variables: Film <chr>, Race <chr>, Gender <chr>, Words <dbl>

``` r
(d <- setdiff(lotr_tidy, lotr_pivtidy)) #Also zero rows different in tidy than in pivot tidy. Excellent!
```

    ## # A tibble: 0 x 4
    ## # … with 4 variables: Film <chr>, Race <chr>, Gender <chr>, Words <dbl>

### Chapter 9 - Reading and Writing files

#### Reading files

Jenny’s advice: use the built-in arguments for data importation to do as
much data wrangling during import as possible, rather than coding it all
in post-import. Read the vignette on column types.

``` r
#Only works if type into console, not via rmd
# vignette("readr")  
```

My only thought is that importing as is and then fussing later allows
you to do data exploration and get a feel for what is in your dataset,
prior to automatically converting, as R might fail silently. So maybe it
depends on how familiar you are with the data and/or if you are using
testing functions to see if there are unexpected things that come up
during the import (i.e. dates or numbers out of range, something getting
converted to an NA which shouldn’t be, etc).

Note that the `forcats` package is used in dealing with factors, eg
reording factor levels. It is loaded as part of the `tidyverse` library.

Also note that (unlike base R) `readr` does NOT convert string to
factors automatically. Thank goodness. But if you know you want to
automatically convert your strings to factor (i.e. from a pre-cleaned
dataset) you can do so using `mutate` as
follows:

``` r
# Locate the actual tsv where gapminder data is stored on local computer; uses 'fs' package
(gap_tsv <- path_package("gapminder", "extdata", "gapminder.tsv"))
```

    ## /Library/Frameworks/R.framework/Versions/3.6/Resources/library/gapminder/extdata/gapminder.tsv

``` r
gapdata <- read_tsv(gap_tsv) %>% 
           mutate(country = factor(country),
                  continent = factor(continent))
```

    ## Parsed with column specification:
    ## cols(
    ##   country = col_character(),
    ##   continent = col_character(),
    ##   year = col_double(),
    ##   lifeExp = col_double(),
    ##   pop = col_double(),
    ##   gdpPercap = col_double()
    ## )

``` r
str(gapdata)
```

    ## Classes 'spec_tbl_df', 'tbl_df', 'tbl' and 'data.frame': 1704 obs. of  6 variables:
    ##  $ country  : Factor w/ 142 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ continent: Factor w/ 5 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...
    ##  $ year     : num  1952 1957 1962 1967 1972 ...
    ##  $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
    ##  $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
    ##  $ gdpPercap: num  779 821 853 836 740 ...

#### Writing files

Make a habit to **save files to non-proprietary formats** unless you
actually cannot. Saving in exotic/proprietary formats will be make it
difficult/impossible for others (or you on a different computer) to
reproduce. Use a format that is readable by a human using a text editor.
I think what she means is avoid .rdata and .rmd as the only way the
analysis is saved, particularly on somethign that is going to have
multiple authors, or datasets that could be used again down the road,
etc vs. a little local project you have. What she means is **DO NOT USE
`save`, `load`, and/or `save.image` commands**, as they are R specific
so you can’t share to a non-R coding colleague. Her typical workflow is
save a text file (eg .csv) and then save (and re-load) an R-specific
binary file using `saveRDS` and `readRDS`. The R-specific binary files
will save your factors that you have carefully re-ordered, otherwise, no
need I think? Note that these files will **not work well with Git diff**
so probably want to add to Gitignore I imagine.

Example of code for writing csv and RDS files and using mutate to
re-order factors with `forcats` package. Note that the **row order of
the dataframe does not change**.

``` r
#Make a useful toy example data summary output
gap_life_exp <- gapdata %>% 
                  group_by(country, continent) %>% 
                  summarize(life_exp = max(lifeExp)) %>% 
                  ungroup()
gap_life_exp 
```

    ## # A tibble: 142 x 3
    ##    country     continent life_exp
    ##    <fct>       <fct>        <dbl>
    ##  1 Afghanistan Asia          43.8
    ##  2 Albania     Europe        76.4
    ##  3 Algeria     Africa        72.3
    ##  4 Angola      Africa        42.7
    ##  5 Argentina   Americas      75.3
    ##  6 Australia   Oceania       81.2
    ##  7 Austria     Europe        79.8
    ##  8 Bahrain     Asia          75.6
    ##  9 Bangladesh  Asia          64.1
    ## 10 Belgium     Europe        79.4
    ## # … with 132 more rows

``` r
head(levels(gap_life_exp$country)) #Currently in alphabetical order of country
```

    ## [1] "Afghanistan" "Albania"     "Algeria"     "Angola"      "Argentina"  
    ## [6] "Australia"

``` r
#Reorder based on increasing life expectancy, using forcats package
gap_life_exp <- gap_life_exp %>% 
                mutate(country = fct_reorder(country, life_exp))
head(levels(gap_life_exp$country)) #Now countries in order of increasing max life expectancy
```

    ## [1] "Sierra Leone" "Angola"       "Afghanistan"  "Liberia"      "Rwanda"      
    ## [6] "Mozambique"

``` r
#Write to csv
write_csv(gap_life_exp, "gap_life_exp_ex.csv")
head("gap_life_exp.csv")
```

    ## [1] "gap_life_exp.csv"

``` r
#Write R-specific binary object file
# saveRDS(gap_life_exp, "gap_life_exp.rds")

#Read the RDS file
# gap_life_exp <- readRDS("gap_life_exp.rds")
```

### Chapter 10 - Factors

Never forget that under the hood, R stores factors as integers\!\!\!

How to get a frequency table of factors - can use `dplyr::count` or
`forcats::fct_count`.

``` r
library(gapminder)
# Dplyr ex
gapminder %>% 
  count(continent)
```

    ## # A tibble: 5 x 2
    ##   continent     n
    ##   <fct>     <int>
    ## 1 Africa      624
    ## 2 Americas    300
    ## 3 Asia        396
    ## 4 Europe      360
    ## 5 Oceania      24

``` r
# Forcats ex
fct_count(gapminder$continent)
```

    ## # A tibble: 5 x 2
    ##   f            n
    ##   <fct>    <int>
    ## 1 Africa     624
    ## 2 Americas   300
    ## 3 Asia       396
    ## 4 Europe     360
    ## 5 Oceania     24

How to drop unused levels - can use either `droplevels()` from base R or
`forcats::fct_drop`.

How to change order of the levels: by default they are ordered
alphabetically. It makes more sense to order variables based on either
(i) frequency or (ii) according to the summary statistic (e.g. mean,
frequency) of another variable. Examples on how to order by frequency
(forwards and backwards):

``` r
# Default
gapminder$continent %>% 
  levels()
```

    ## [1] "Africa"   "Americas" "Asia"     "Europe"   "Oceania"

``` r
# Order by highest frequency first
gapminder$continent %>% 
  fct_infreq() %>%
  levels()
```

    ## [1] "Africa"   "Asia"     "Europe"   "Americas" "Oceania"

``` r
# Order by lowest frequency first
gapminder$continent %>% 
  fct_infreq() %>% 
  fct_rev() %>% 
  levels()
```

    ## [1] "Oceania"  "Americas" "Europe"   "Asia"     "Africa"

Examples of how to order by another variable:

``` r
# Order countries by median life expectancy
fct_reorder(gapminder$country, gapminder$lifeExp) %>% 
  levels() %>% 
  head()
```

    ## [1] "Sierra Leone"  "Guinea-Bissau" "Afghanistan"   "Angola"       
    ## [5] "Somalia"       "Guinea"

``` r
# Order according to minimum life expectancy (i.e. a different summary stat) instead of median
fct_reorder(gapminder$country, gapminder$lifeExp, min) %>% 
  levels() %>% 
  head()
```

    ## [1] "Rwanda"       "Afghanistan"  "Gambia"       "Angola"       "Sierra Leone"
    ## [6] "Cambodia"

``` r
# Order countries by median life expectancy, backwards (i.e. highest median lifExp first)
fct_reorder(gapminder$country, gapminder$lifeExp, .desc = T) %>% 
  levels() %>% 
  head()
```

    ## [1] "Iceland"     "Japan"       "Sweden"      "Switzerland" "Netherlands"
    ## [6] "Norway"

Examples of how useful this can be for Cleveland plots. Note that you
should use `forcats::fct_reorder2` when you have a line chart of
quantitative x vs another quantitative y and your factor is used for
color…this is because **the legend will be in the same order as the
levels of the factor\!** Thank goodness.

``` r
gap_asia_2007 <- gapminder %>% filter(year == 2007, continent == "Asia")

# Unordered
ggplot(gap_asia_2007, aes(x = lifeExp, y = country)) + geom_point()
```

![](stat545_data_analysis_MC_files/figure-gfm/Dot%20plots%20with%20factors-1.png)<!-- -->

``` r
# Ordered
ggplot(gap_asia_2007, aes(x = lifeExp, y = fct_reorder(country, lifeExp))) +
  geom_point()
```

![](stat545_data_analysis_MC_files/figure-gfm/Dot%20plots%20with%20factors-2.png)<!-- -->

``` r
# Using fct_reorder2() to ensure legend is in same order as the data
h_countries <- c("Egypt", "Haiti", "Romania", "Thailand", "Venezuela")
h_gap <- gapminder %>%
  filter(country %in% h_countries) %>% 
  droplevels()

ggplot(h_gap, aes(x = year, y = lifeExp,
                  color = fct_reorder2(country, year, lifeExp))) +
  geom_line() +
  labs(color = "country")
```

![](stat545_data_analysis_MC_files/figure-gfm/Dot%20plots%20with%20factors-3.png)<!-- -->

You can also reorder factors in a more manual way using `fct_relevel`.
For instance, you might want one or two levels first, while you don’t
really care about the remaining order (i.e. you want to compare Canada
vs the rest of the world). You can also manually rename levels using
`fct_recode`. Lastly, you can combine a factor variable in two
dataframes **with different levels** by using `forcats::fct_c`. If you
just normally concatenate using `base::c` it will add them as numeric
variables, due to how factors are stored under the hood in R. Note that
alternatively you can use `bind_rows` when combining dataframes as it
will coerce the factor variable back to a character class to combine the
two.

``` r
# Bring one or two factors to the front
h_gap$country %>% levels()
```

    ## [1] "Egypt"     "Haiti"     "Romania"   "Thailand"  "Venezuela"

``` r
h_gap$country %>% fct_relevel("Romania", "Haiti") %>% levels()
```

    ## [1] "Romania"   "Haiti"     "Egypt"     "Thailand"  "Venezuela"

``` r
# Rename your factors
i_gap <- gapminder %>% 
  filter(country %in% c("United States", "Sweden", "Australia")) %>% 
  droplevels()
i_gap$country %>% levels()
```

    ## [1] "Australia"     "Sweden"        "United States"

``` r
i_gap$country %>%
  fct_recode("USA" = "United States", "Oz" = "Australia") %>% levels()
```

    ## [1] "Oz"     "Sweden" "USA"

``` r
# Combining a factor variable with different levels
df1 <- gapminder %>%
  filter(country %in% c("United States", "Mexico"), year > 2000) %>%
  droplevels()
df2 <- gapminder %>%
  filter(country %in% c("France", "Germany"), year > 2000) %>%
  droplevels()

c(df1$country, df2$country)
```

    ## [1] 1 1 2 2 1 1 2 2

``` r
fct_c(df1$country, df2$country)
```

    ## [1] Mexico        Mexico        United States United States France       
    ## [6] France        Germany       Germany      
    ## Levels: Mexico United States France Germany

### Chapter 11 - Characters

Great packages to use with characters:

  - `stringr`

  - `tidyr` (to split one character vector into many and vice versa
    using `separate`, `unite`, and `extract`)

  - baseR (`nchar`, `strsplit`, `substr`, `paste`, `paste0`)

  - `glue` package for string interpolation (especially if
    `stringr::str_interp` isn’t enough).

Regular expression resources:

  - The [Strings chapter](https://r4ds.had.co.nz/strings.html) of R for
    Data Science ebook. Also a good resource for looking up how to use
    groups and backreferences, which are not discussed here.

  - `rex` R package, as it uses

  - baseR (`grep`, `grepl`, etc)

  - REgex testers to see if your regular expression will actually work
    on a test string of your devising: [regex101](https://regex101.com)
    (This one has a very friendly interface for beginner users) and
    [regexr](https://regexr.com) (probably just as good but looks a
    little more daunting?)

#### Stringr functions - overview

Useful stringr functions:

  - `str_detect` You can either use a literal string or a regular
    expression for your pattern. This function returns a vector of
    TRUE/FALSE for each instance of your string data (i.e. number of
    rows in your dataframe).

  - `str_subset` This function returns a vector of matching character
    strings. Thus, it allows you keep only the matching elements
    (i.e. those strings that would match as TRUE in the above vector).

  - `str_split` allows you to split a string based on a delimiter, which
    is the pattern argument. It returns a list, which is a bit of a pain
    in the butt, but necessary as there could be a variable number of
    elements returned for each split character string.

  - `str_split_fixed` is the same as `str_split` but if you know there
    will be only a certain number of elements for each split string
    (i.e. sampleIDs such as LAX-s20 split on the ‘-’ delimiter will
    always have 2 pieces), then you can specify the number of pieces and
    return a character
    matrix.

<!-- end list -->

``` r
(my_fruit <- str_subset(fruit, pattern = "fruit"))
```

    ## [1] "breadfruit"   "dragonfruit"  "grapefruit"   "jackfruit"    "kiwi fruit"  
    ## [6] "passionfruit" "star fruit"   "ugli fruit"

``` r
str_split_fixed(my_fruit, pattern = " ", n = 2)
```

    ##      [,1]           [,2]   
    ## [1,] "breadfruit"   ""     
    ## [2,] "dragonfruit"  ""     
    ## [3,] "grapefruit"   ""     
    ## [4,] "jackfruit"    ""     
    ## [5,] "kiwi"         "fruit"
    ## [6,] "passionfruit" ""     
    ## [7,] "star"         "fruit"
    ## [8,] "ugli"         "fruit"

  - `separate` is similar to `str_split` family but works when variable
    is in a dataframe. Also, very useful in that it will let you enter
    missing values into columns if there are unequal number of pieces.

<!-- end list -->

``` r
# Without using fill argument (default is to warn and then right fill)
my_fruit_df <- tibble(my_fruit)
my_fruit_df %>% 
  separate(my_fruit, into = c("pre", "post"), sep = " ")
```

    ## Warning: Expected 2 pieces. Missing pieces filled with `NA` in 5 rows [1, 2, 3,
    ## 4, 6].

    ## # A tibble: 8 x 2
    ##   pre          post 
    ##   <chr>        <chr>
    ## 1 breadfruit   <NA> 
    ## 2 dragonfruit  <NA> 
    ## 3 grapefruit   <NA> 
    ## 4 jackfruit    <NA> 
    ## 5 kiwi         fruit
    ## 6 passionfruit <NA> 
    ## 7 star         fruit
    ## 8 ugli         fruit

``` r
# With fill argument, right pad
my_fruit_df %>% 
  separate(my_fruit, into = c("pre", "post"), sep = " ", fill = "right")
```

    ## # A tibble: 8 x 2
    ##   pre          post 
    ##   <chr>        <chr>
    ## 1 breadfruit   <NA> 
    ## 2 dragonfruit  <NA> 
    ## 3 grapefruit   <NA> 
    ## 4 jackfruit    <NA> 
    ## 5 kiwi         fruit
    ## 6 passionfruit <NA> 
    ## 7 star         fruit
    ## 8 ugli         fruit

``` r
# With fill argument, left pad
my_fruit_df %>% 
  separate(my_fruit, into = c("pre", "post"), sep = " ", fill = "left")
```

    ## # A tibble: 8 x 2
    ##   pre   post        
    ##   <chr> <chr>       
    ## 1 <NA>  breadfruit  
    ## 2 <NA>  dragonfruit 
    ## 3 <NA>  grapefruit  
    ## 4 <NA>  jackfruit   
    ## 5 kiwi  fruit       
    ## 6 <NA>  passionfruit
    ## 7 star  fruit       
    ## 8 ugli  fruit

  - `str_length` counts the length of each character string within the
    vector

  - `str_sub` lets you snip out substrings based on character position.
    The start and end arguments are vectorized, meaning they can provide
    a sliding window (for ex, a sliding 3-character window when using a
    vector rather than just an integer). It can also be used for
    replacing substrings when placed on the lefthand side of the
    assignment operator.

<!-- end list -->

``` r
# Based just on a single position
head(fruit) %>% 
  str_sub(start = 1, end = 3)
```

    ## [1] "app" "apr" "avo" "ban" "bel" "bil"

``` r
# Using a sliding window
tibble(fruit) %>% 
  head() %>% 
  mutate(snip = str_sub(string = fruit, start = 1:6, end = 3:8)) 
```

    ## # A tibble: 6 x 2
    ##   fruit       snip 
    ##   <chr>       <chr>
    ## 1 apple       "app"
    ## 2 apricot     "pri"
    ## 3 avocado     "oca"
    ## 4 banana      "ana"
    ## 5 bell pepper " pe"
    ## 6 bilberry    "rry"

``` r
#oddly, it seems like pipe doesn't work well inside a second function within mutate??? ie need to re-specify fruit as the string argument for str_sub, but don't need to do so for mutate...I don't really get why but good to know for future trouble-shooting

# Replacement of substrings
(x <- head(fruit, 3))
```

    ## [1] "apple"   "apricot" "avocado"

``` r
str_sub(x, 1, 3) <- "AAA"
x
```

    ## [1] "AAAle"   "AAAicot" "AAAcado"

  - `str_c` allows you to collapse a vector to a single string. Seems
    kinda useless but I guess it’s mostly useful as a precursor for
    other operations you might want to do later (i.e. string encoding?).
    You can also do advanced mode by concatenating multiple element
    wise, with or without collasping the elements into a single string

<!-- end list -->

``` r
# Collapse into a single vector
head(fruit) %>% 
  str_c(collapse = ", ")
```

    ## [1] "apple, apricot, avocado, banana, bell pepper, bilberry"

``` r
# Glue multiple elements together into mutliple strings
str_c(fruit[1:4], fruit[5:8], sep = " & ")
```

    ## [1] "apple & bell pepper"   "apricot & bilberry"    "avocado & blackberry" 
    ## [4] "banana & blackcurrant"

``` r
# Glue multiple elements together AND collapse into one string
str_c(fruit[1:4], fruit[5:8], sep = " & ", collapse = ", ")
```

    ## [1] "apple & bell pepper, apricot & bilberry, avocado & blackberry, banana & blackcurrant"

  - `unite` allows you to combine vectors that are variables in a
    dataframe into a single new variable.

<!-- end list -->

``` r
fruit_df <- tibble(
  fruit1 = fruit[1:4],
  fruit2 = fruit[5:8])

fruit_df %>% 
  unite("flavor_combo", fruit1, fruit2, sep = " & ")
```

    ## # A tibble: 4 x 1
    ##   flavor_combo         
    ##   <chr>                
    ## 1 apple & bell pepper  
    ## 2 apricot & bilberry   
    ## 3 avocado & blackberry 
    ## 4 banana & blackcurrant

  - `str_replace` allows you to replace a string or substring using
    either a character pattern or regex pattern. A special case is
    `str_replace_na` for when you are trying to replace any ’NA’s with a
    pattern. Similarly, `tidyr::replace_na` can be used within a
    dataframe. Note the use of `list` function to do so
    though\!\!\!

<!-- end list -->

``` r
str_replace(my_fruit, pattern = "fruit", replacement = "THINGY")
```

    ## [1] "breadTHINGY"   "dragonTHINGY"  "grapeTHINGY"   "jackTHINGY"   
    ## [5] "kiwi THINGY"   "passionTHINGY" "star THINGY"   "ugli THINGY"

``` r
melons <- str_subset(fruit, pattern = "melon")
melons[2] <- NA
melons
```

    ## [1] "canary melon" NA             "watermelon"

``` r
str_replace_na(melons, "UNKNOWN MELON")
```

    ## [1] "canary melon"  "UNKNOWN MELON" "watermelon"

``` r
tibble(melons) %>% 
  replace_na(replace = list(melons = "UNKNOWN MELON"))
```

    ## # A tibble: 3 x 1
    ##   melons       
    ##   <chr>        
    ## 1 canary melon 
    ## 2 UNKNOWN MELON
    ## 3 watermelon

#### Regular expressions with stringr - overview

Sigh. Oh regular expressions. As her quote says “combining slashes and
dots until a thing happens”. My feelings exactly. Except usually it’s
not the thing I intend to happen.

I’m basically going to copy the entire regex section text, examples, and
all because I find it so difficult.

*Important points on regex:*

  - It is case sensitive. i.a will match "Argent**i**n**a** but not
    **I**t**a**ly

  - You will need to **escape** any special characters (eg `\`) with a
    backslash. Meaning that in R, all the regular expressions starting
    with a backslash actually need to be typed with two backslashes (eg
    new line looks like `\\n` when written in R code).

*Regex characters:*

  - `.` indicates any single character, except for a newline. Ex) `a.b`
    will match all countries that have an `a`, followed by any single
    character, followed by a `b`.

  - `\n` stands for newline

  - `^` is an anchor (i.e. used to express where the expression must
    occur within a string) for the **beginning** of the string.

  - `$` is an anchor for the **end** of the string

  - `\b` is a word boundary

  - `\B` is **not** a word boundary

<!-- end list -->

``` r
countries <- levels(gapminder$country)

str_subset(countries, pattern = "i.a")
```

    ##  [1] "Argentina"                "Bosnia and Herzegovina"  
    ##  [3] "Burkina Faso"             "Central African Republic"
    ##  [5] "China"                    "Costa Rica"              
    ##  [7] "Dominican Republic"       "Hong Kong, China"        
    ##  [9] "Jamaica"                  "Mauritania"              
    ## [11] "Nicaragua"                "South Africa"            
    ## [13] "Swaziland"                "Taiwan"                  
    ## [15] "Thailand"                 "Trinidad and Tobago"

``` r
str_subset(countries, pattern = "i.a$")
```

    ## [1] "Argentina"              "Bosnia and Herzegovina" "China"                 
    ## [4] "Costa Rica"             "Hong Kong, China"       "Jamaica"               
    ## [7] "South Africa"

``` r
str_subset(my_fruit, pattern = "d")
```

    ## [1] "breadfruit"  "dragonfruit"

``` r
str_subset(my_fruit, pattern = "^d")
```

    ## [1] "dragonfruit"

``` r
str_subset(fruit, pattern = "melon")
```

    ## [1] "canary melon" "rock melon"   "watermelon"

``` r
str_subset(fruit, pattern = "\\bmelon")
```

    ## [1] "canary melon" "rock melon"

``` r
str_subset(fruit, pattern = "\\Bmelon")
```

    ## [1] "watermelon"

  - `[]` square brackets around something indicates it is a type of
    ‘character class’.

  - A whitespace character can be represented by `\s` (a metacharacter)
    or by `[:space:]` (which belongs to POSIX
class).

<!-- end list -->

``` r
# Adding quotes to a character string (easier string example than whitespace...)
cat("Do you use \"airquotes\" much?")
```

    ## Do you use "airquotes" much?

``` r
# Spliting using a human-readable character string
str_split_fixed(fruit, pattern = " ", n = 2)
```

    ##       [,1]           [,2]        
    ##  [1,] "apple"        ""          
    ##  [2,] "apricot"      ""          
    ##  [3,] "avocado"      ""          
    ##  [4,] "banana"       ""          
    ##  [5,] "bell"         "pepper"    
    ##  [6,] "bilberry"     ""          
    ##  [7,] "blackberry"   ""          
    ##  [8,] "blackcurrant" ""          
    ##  [9,] "blood"        "orange"    
    ## [10,] "blueberry"    ""          
    ## [11,] "boysenberry"  ""          
    ## [12,] "breadfruit"   ""          
    ## [13,] "canary"       "melon"     
    ## [14,] "cantaloupe"   ""          
    ## [15,] "cherimoya"    ""          
    ## [16,] "cherry"       ""          
    ## [17,] "chili"        "pepper"    
    ## [18,] "clementine"   ""          
    ## [19,] "cloudberry"   ""          
    ## [20,] "coconut"      ""          
    ## [21,] "cranberry"    ""          
    ## [22,] "cucumber"     ""          
    ## [23,] "currant"      ""          
    ## [24,] "damson"       ""          
    ## [25,] "date"         ""          
    ## [26,] "dragonfruit"  ""          
    ## [27,] "durian"       ""          
    ## [28,] "eggplant"     ""          
    ## [29,] "elderberry"   ""          
    ## [30,] "feijoa"       ""          
    ## [31,] "fig"          ""          
    ## [32,] "goji"         "berry"     
    ## [33,] "gooseberry"   ""          
    ## [34,] "grape"        ""          
    ## [35,] "grapefruit"   ""          
    ## [36,] "guava"        ""          
    ## [37,] "honeydew"     ""          
    ## [38,] "huckleberry"  ""          
    ## [39,] "jackfruit"    ""          
    ## [40,] "jambul"       ""          
    ## [41,] "jujube"       ""          
    ## [42,] "kiwi"         "fruit"     
    ## [43,] "kumquat"      ""          
    ## [44,] "lemon"        ""          
    ## [45,] "lime"         ""          
    ## [46,] "loquat"       ""          
    ## [47,] "lychee"       ""          
    ## [48,] "mandarine"    ""          
    ## [49,] "mango"        ""          
    ## [50,] "mulberry"     ""          
    ## [51,] "nectarine"    ""          
    ## [52,] "nut"          ""          
    ## [53,] "olive"        ""          
    ## [54,] "orange"       ""          
    ## [55,] "pamelo"       ""          
    ## [56,] "papaya"       ""          
    ## [57,] "passionfruit" ""          
    ## [58,] "peach"        ""          
    ## [59,] "pear"         ""          
    ## [60,] "persimmon"    ""          
    ## [61,] "physalis"     ""          
    ## [62,] "pineapple"    ""          
    ## [63,] "plum"         ""          
    ## [64,] "pomegranate"  ""          
    ## [65,] "pomelo"       ""          
    ## [66,] "purple"       "mangosteen"
    ## [67,] "quince"       ""          
    ## [68,] "raisin"       ""          
    ## [69,] "rambutan"     ""          
    ## [70,] "raspberry"    ""          
    ## [71,] "redcurrant"   ""          
    ## [72,] "rock"         "melon"     
    ## [73,] "salal"        "berry"     
    ## [74,] "satsuma"      ""          
    ## [75,] "star"         "fruit"     
    ## [76,] "strawberry"   ""          
    ## [77,] "tamarillo"    ""          
    ## [78,] "tangerine"    ""          
    ## [79,] "ugli"         "fruit"     
    ## [80,] "watermelon"   ""

``` r
# Spliting using a metacharacter
str_split_fixed(my_fruit, pattern = "\\s", n = 2)
```

    ##      [,1]           [,2]   
    ## [1,] "breadfruit"   ""     
    ## [2,] "dragonfruit"  ""     
    ## [3,] "grapefruit"   ""     
    ## [4,] "jackfruit"    ""     
    ## [5,] "kiwi"         "fruit"
    ## [6,] "passionfruit" ""     
    ## [7,] "star"         "fruit"
    ## [8,] "ugli"         "fruit"

``` r
# Spliting using POSIX class
str_split_fixed(my_fruit, pattern = "[[:space:]]", n = 2)
```

    ##      [,1]           [,2]   
    ## [1,] "breadfruit"   ""     
    ## [2,] "dragonfruit"  ""     
    ## [3,] "grapefruit"   ""     
    ## [4,] "jackfruit"    ""     
    ## [5,] "kiwi"         "fruit"
    ## [6,] "passionfruit" ""     
    ## [7,] "star"         "fruit"
    ## [8,] "ugli"         "fruit"

  - If you use a special character in a string in R, you need to tell R
    to use it as a character by escaping it. This is done by adding a
    single backslash. However, if you are using a special character
    within a regular expression, R reads it as a character string first
    before interpreting as a regex…so you need to escape the backslash,
    and you end up needing **TWO** backslashes. Also note that if you
    are using a POSIX class within a regular expression you need to
    escape by using two sets of square brackets.

  - Other examples of escaping special characters include:
    
      - periods (need to write as `\.` in normal string or `\\.` within
        a regular expression)
      - square brackets (need to write as `\[` in normal string or `\\[`
        within a regular expression),
      - quotes inside of quotes (need to write as `\"` in normal string
        or `\\"` within a regular expression)
      - newline (need to write as `\n` in normal string or `\\n` within
        a regular expression)
      - tab (need to write as `\t` in normal string or `\\t` within a
        regular expression)
      - space (need to write as `\s` in normal string or `\\s` within a
        regular expression)

  - `[:punct:]` looks for a string containing punctuation

  - `\d` stands for character class digit

  - Quantifiers. These symbols indicate how many characters (or
    metacharacters, or classes, etc) the pattern is allowed to match.
    
      - `*` indicates 0 or more; so for {n} match exactly ‘n’
      - `+` indicates 1 or more; so for {n} match at least ‘n’
      - `?` indicates 0 or 1; so for { ,m} match at most ‘m’ and for
        {n,m} match between ‘n’ and ‘m’, inclusive

<!-- end list -->

``` r
# Most inclusive example 
  #'l.*e' will match strings with 0 or more characters between, 
  #thus a string with an 'l' eventually followed by an 'e'
(matches <-  str_subset(fruit, pattern = "l.*e"))
```

    ##  [1] "apple"             "bell pepper"       "bilberry"         
    ##  [4] "blackberry"        "blood orange"      "blueberry"        
    ##  [7] "cantaloupe"        "chili pepper"      "clementine"       
    ## [10] "cloudberry"        "elderberry"        "huckleberry"      
    ## [13] "lemon"             "lime"              "lychee"           
    ## [16] "mulberry"          "olive"             "pineapple"        
    ## [19] "purple mangosteen" "salal berry"

``` r
# Less inclusive example 
  #'l.+e' will match strings with 1 or more characters between,
  #thus will no longer match 'le'
list(match = intersect(matches, str_subset(fruit, pattern = "l.+e")),
     no_match = setdiff(matches, str_subset(fruit, pattern = "l.+e")))
```

    ## $match
    ##  [1] "bell pepper"       "bilberry"          "blackberry"       
    ##  [4] "blood orange"      "blueberry"         "cantaloupe"       
    ##  [7] "chili pepper"      "clementine"        "cloudberry"       
    ## [10] "elderberry"        "huckleberry"       "lime"             
    ## [13] "lychee"            "mulberry"          "olive"            
    ## [16] "purple mangosteen" "salal berry"      
    ## 
    ## $no_match
    ## [1] "apple"     "lemon"     "pineapple"

``` r
# Another less inclusive example
  #'l.?e' will match strings with at MOST 1 character between,
  #Thus the EXcluded strings have 2 or more characters between 'l' and 'e'
list(match = intersect(matches, str_subset(fruit, pattern = "l.?e")),
     no_match = setdiff(matches, str_subset(fruit, pattern = "l.?e")))
```

    ## $match
    ##  [1] "apple"             "bilberry"          "blueberry"        
    ##  [4] "clementine"        "elderberry"        "huckleberry"      
    ##  [7] "lemon"             "mulberry"          "pineapple"        
    ## [10] "purple mangosteen"
    ## 
    ## $no_match
    ##  [1] "bell pepper"  "blackberry"   "blood orange" "cantaloupe"   "chili pepper"
    ##  [6] "cloudberry"   "lime"         "lychee"       "olive"        "salal berry"

``` r
# Final less inclusive example
  #'le' removes the quantifier and matches ONLY strings with exactly 'le'
  list(match = intersect(matches, str_subset(fruit, pattern = "le")),
     no_match = setdiff(matches, str_subset(fruit, pattern = "le")))
```

    ## $match
    ## [1] "apple"             "clementine"        "huckleberry"      
    ## [4] "lemon"             "pineapple"         "purple mangosteen"
    ## 
    ## $no_match
    ##  [1] "bell pepper"  "bilberry"     "blackberry"   "blood orange" "blueberry"   
    ##  [6] "cantaloupe"   "chili pepper" "cloudberry"   "elderberry"   "lime"        
    ## [11] "lychee"       "mulberry"     "olive"        "salal berry"

### Chapter 13 - Dates and times

The take home is to use `lubridate`. And read up on it in the R for Data
Science [chapter](https://r4ds.had.co.nz/dates-and-times.html).

Also - apparently date times are printed within tibbles as `<dttm>` but
elsewhere in R are refered to as `POSIXct`. Ah\!

Another big take home (which I have learnt the hard way…) is use the
simplest class possible. If you need a date, use a `date` class, instead
of `date-time` class; similarly if you need a time, use a `time` class
(best done through using the `hms` package).

If you need to switch between a date-time to a date use `as_date`. To
switch from a date to a date-time, use `as_datetime`.

#### Extracting and editing dates (or datetimes) from character strings

Use lubridate functions, based on the format of the string (eg `ymd`,
`mdy`, and `dmy`). The string can be quoted or unquoted. To create a
date-time, add an underscore with the time component (eg `ymd_hms` or
`mdy_hm`). Alternatively, adding the time zone argument (`tz =`) within
a date function will also give a date-time. Time zones are a bit of a
pain in the butt and I’ve never had to deal with converting them, so for
now, I’ll leave it off of this summary sheet (but R for Data Science has
more info on it if needed, as well as the raw time zone database
[website](http://www.iana.org/time-zones)).

You can paste together multiple columns to make a date (`make_date`) or
datetime (`make_datetime`).

``` r
library(lubridate)
```

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:base':
    ## 
    ##     date

``` r
library(nycflights13)
#Note do NOT try to use 'datatable' to format this, as the dataset is WAY too big and it makes R freeze
flights %>% 
  select(year, month, day, hour, minute) %>% 
  mutate(departure = make_datetime(year, month, day, hour, minute))
```

    ## # A tibble: 336,776 x 6
    ##     year month   day  hour minute departure          
    ##    <int> <int> <int> <dbl>  <dbl> <dttm>             
    ##  1  2013     1     1     5     15 2013-01-01 05:15:00
    ##  2  2013     1     1     5     29 2013-01-01 05:29:00
    ##  3  2013     1     1     5     40 2013-01-01 05:40:00
    ##  4  2013     1     1     5     45 2013-01-01 05:45:00
    ##  5  2013     1     1     6      0 2013-01-01 06:00:00
    ##  6  2013     1     1     5     58 2013-01-01 05:58:00
    ##  7  2013     1     1     6      0 2013-01-01 06:00:00
    ##  8  2013     1     1     6      0 2013-01-01 06:00:00
    ##  9  2013     1     1     6      0 2013-01-01 06:00:00
    ## 10  2013     1     1     6      0 2013-01-01 06:00:00
    ## # … with 336,766 more rows

You can also get components of a date or time using the following
functions from lubridate: `year`, `month`, `mday` (for day of the
month), `yday` (for day of the year), `wday` (for day of the week),
`hour`, `minute`, and `second`. Additional arguments for `month` and
`wday` include setting `label = T` to get the abbreviated name of the
month or day of the week, while `abbr = F` returns the full
name.

``` r
#Times are in a weird format in 'flights' so this function uses modulus arithmetic to get hour and min 
  #Note that times are listed as 515 for 05:15hr
    #and 515 %/% 100 returns 5
    #while 515 %% 100 returns 15
make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100) 
}

#Make a new flights dataframe with datatimes
flights_dt <- flights %>% 
  filter(!is.na(dep_time), !is.na(arr_time)) %>% 
  mutate(dep_time = make_datetime_100(year, month, day, dep_time),
         arr_time = make_datetime_100(year, month, day, arr_time),
         sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
         sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>% 
  select(origin, dest, ends_with("delay"), ends_with("time"))

#Make a bar chart to see the number of flights departing on weekdays vs weekend days
flights_dt %>% 
  mutate(wday = wday(dep_time, label = T)) %>% 
  ggplot(aes(x = wday)) +
    geom_bar()
```

![](stat545_data_analysis_MC_files/figure-gfm/flights%20by%20wday%20plot-1.png)<!-- -->
You can set/edit components of a date/time using those same accessor
functions (eg `month`). Likely even more useful is the `update`
function, which creates a NEW object and allows you set multiple values
at once, and will rollover values that are too big. This can be useful
in setting larger components of a date to a constant so that you can
explore patterns in the smaller components; for instance, to show the
distribution of flights over the course of a day for every day of the
year, as below.

``` r
(datetime <- ymd_hms("2016-07-18 12:34:56"))
```

    ## [1] "2016-07-18 12:34:56 UTC"

``` r
#Edit one component in a date
year(datetime) <- 2020
datetime
```

    ## [1] "2020-07-18 12:34:56 UTC"

``` r
#Edit multiple components in a year
update(datetime, year = 2012, month = 2, mday = 2, hour = 2)
```

    ## [1] "2012-02-02 02:34:56 UTC"

``` r
datetime #Note this does NOT edit the original datetime, but creates a NEW object!!!
```

    ## [1] "2020-07-18 12:34:56 UTC"

``` r
#Roll over in dates when editing with update
ymd("2015-02-01") %>% 
  update(mday = 30)
```

    ## [1] "2015-03-02"

``` r
#Setting year date to a constant to explore patterns in flight times over the course of 24h
flights_dt %>% 
  mutate(dep_hour = update(dep_time, yday = 1)) %>% 
  ggplot(aes(dep_hour)) +
    geom_freqpoly(binwidth = 300)
```

![](stat545_data_analysis_MC_files/figure-gfm/editing%20dates-1.png)<!-- -->

You can also ROUND dates to a unit of time desired. You can round down
(`floor_date`), round up (`ceiling_date`), or round to the nearest (just
`round_date`). Apparently, this is most useful when trying to calculate
difference between a rounded and unrounded date (but no examples
provided…).

``` r
flights_dt %>% 
  count(week = floor_date(dep_time, "week")) %>% 
  ggplot(aes(week, n)) +
  geom_line()
```

![](stat545_data_analysis_MC_files/figure-gfm/rounding%20dates-1.png)<!-- -->

#### Time spans

This is what allows you to do subtraction, addition, and division with
dates. Time spans are represented in 3 ways:

  - durations = represents an extact number of seconds

  - periods = represents human units like weeks and months

  - intervals = represents a starting and ending point

Which to choose? Always choose the simplest data structure that solves
your problem. If you care about physical time, use duration; if you need
to add human times, use a period; if you need to figure out how long a
span is in human units, use an interval. Additional details and examples
are below.

**DURATIONS** When you substract two dates you get a `difftime` object,
which records a time span of seconds, minutes, hours, days or weeks…so
lubridate’s duration functions always uses seconds. All duration
functions are preceded with `d`: `dseconds`, `dminutes`, `dhours`,
`ddays`, `dweeks`, and `dyears`. Note that the results of date
arithemtic in durations may sometimes surprise you, as it adjusts for
differences in time zones and time changes due to daylight savings
times\!\!\!

**PERIODS** Periods are often more inutitive to work with than durations
(but less exact, as they don’t have a fixed length in seconds). These
functions are just the ‘normal human’ names we give to times (in the
PLURAL form\!\!\!): `seconds`, `minutes`, `hours`, `days`, `months`,
`weeks`, and `years`. As with durations, you can add, substract and
multiply periods or to other dates. Unlike durations, the results do not
take into account leap years, or daylight savings times, but probably
end up giving a result you actually respect (see below).

``` r
# A leap year
ymd("2016-01-01") + dyears(1)
```

    ## [1] "2016-12-31"

``` r
ymd("2016-01-01") + years(1)
```

    ## [1] "2017-01-01"

``` r
# Daylight Savings Time
one_pm <- ymd_hms("2016-03-12 13:00:00", tz = "America/New_York")
one_pm + ddays(1)
```

    ## [1] "2016-03-13 14:00:00 EDT"

``` r
one_pm + days(1)
```

    ## [1] "2016-03-13 13:00:00 EDT"

**INTERVALS** An interval is a duration with a starting point and an end
point, this makes it precise so you can determine exactly how long it
is. You make an interval using the `%--%` operator.

``` r
# Arithmatic with periods are not accurate, so will get a warning
years(1) / days(1)
```

    ## estimate only: convert to intervals for accuracy

    ## [1] 365.25

``` r
# Arithmatic with intervals is more precise
next_year <- today() + years(1)
(today() %--% next_year) /ddays(1)
```

    ## [1] 365

To find out how many periods fall into an interval, you need to use
integer
    division.

``` r
(today() %--% next_year) %/% days(1)
```

    ## Note: method with signature 'Timespan#Timespan' chosen for function '%/%',
    ##  target signature 'Interval#Period'.
    ##  "Interval#ANY", "ANY#Period" would also be valid

    ## [1] 365

### Chapter 14, 15, and 16 - Combining dfs with bind, join, and lookup

You should be cautious when binding rows that the columns are aligned
and the data in each column is the same type. Use `dplyr::bind_rows`,
which looks for these issues (unlike `base::rbind`). You should
**ALWAYS** inspect the results.

Avoid column binding in particular as it is difficult to know if the
rows are exactly aligned - this is YOUR JOB as the data analyst if you
use functions like `dplyr::bind_cols`. Or there is the standalone
`tibble::add_column`, which just adds a column\! With data frames, it is
much better to use dplyr’s `mutate` or tidyr’s `seperate` as they use
mechanisms to ensure row alignment is definitely correct. And actually a
join is probably the gold standard of how to add columns to a dataframe
(or table), from another dataframe (or table). Take home as per JB:
column bind only if you must and be extremely paranoid\!\!\!\!

Joins - a good summary of which function does what is on the second page
of the dplyr data wrangling cheat sheet from RStudio
[here](https://4.files.edl.io/b9e2/07/12/19/142839-a23788fb-1d3a-4665-9dc4-33bfd442c296.pdf).

  - Note that a `semi_join` is a filtering join, meaning that—although
    they both return all rows from `x` that have matching values in
    `y`—it differs from an `inner_join` because an inner join will
    duplicate `x` across rows of matching `y`, while `semi_join` will
    never duplicate `x`. This is useful to sanity check your joins by
    seeing what **will** be joined.

  - Don’t forget that you can use another filtering join (`anti_join`)
    as a way to find all rows in `x` that do not have a matching value
    in `y` (keeping only columns in `x`). This is very handy for sanity
    checking your joins to see what **will not** be joined.

Lookup is a special case of join where there is one dataframe (or table)
and one vector. This mimics Excel’s `LOOKUP()` function. It uses the
`match(x, table)` function, where values in the key `x` appear in the
lookup variable `table`. In table lookup, there is also always a
variable `y` (used to index with the `match(x, table)` results). The `y`
needs to be the same length and same row order as `table` and typically
resides in the same data frame (or table) as `table`.

  - Note `match` returns **indices** (i.e. positive integers) and
    assumes both `x` and `table` are free-range vectors (i.e. not in a
    data frame).

  - `match` also allows for multiple matches by only consulting the
    first.

Steps for replicating Excel’s `LOOKUP` function using match are listed
below. Note that in this case, we’ve just replicated what `inner_join`
does, but there are times when it is useful to it this way.

  - 1)  Use match to get a vector of indices.

  - 2)  Double check it makes sense (and you haven’t reversed x and
        table, which is easy to do) by adding an ‘x’ column to the
        original dataframe, from your index and table values and
        printing it to the console. Note that this just lives in the
        console (or make a test data frame if it’s too large); do NOT
        need to add this to your main table\!

  - 3)  Once you’ve sanity checked it looks accurate, do the table
        lookup and add the new info (as applicable) to your main table.

<!-- end list -->

``` r
# Create a new dataframe from subset of gapminder
mini_gap <- gapminder %>% 
  filter(country %in% c("Belgium", "Canada", "United States", "Mexico"), year > 2000) %>% 
  select(-pop, -gdpPercap) %>% 
  droplevels()

# Make a dataframe of sterotypical national foods. Note there is no Mexico here!
food <- tribble(
          ~country, ~food,
          "Belgium", "waffle",
          "Canada", "poutine",
          "United States", "Twinkie"
)

### How to lookup a national food 
# i) use match to get a vector of indices
(indices <- match(x = mini_gap$country, 
                  table = food$country))
```

    ## [1]  1  1  2  2 NA NA  3  3

``` r
# ii) Double check it makes sense (and you haven't reversed x and table)
  #by adding an 'x' column to the original dataframe, from your index and table values
  #Note that this just lives in the console or make a test data frame; NOT your main table!
add_column(food[indices, ], x = mini_gap$country)
```

    ## # A tibble: 8 x 3
    ##   country       food    x            
    ##   <chr>         <chr>   <fct>        
    ## 1 Belgium       waffle  Belgium      
    ## 2 Belgium       waffle  Belgium      
    ## 3 Canada        poutine Canada       
    ## 4 Canada        poutine Canada       
    ## 5 <NA>          <NA>    Mexico       
    ## 6 <NA>          <NA>    Mexico       
    ## 7 United States Twinkie United States
    ## 8 United States Twinkie United States

``` r
# iii) Once you've sanity checked it looks accurate, do the table lookup
  #and add the new info (as applicable) to your main table
mini_gap %>% 
  mutate(food = food$food[indices])
```

    ## # A tibble: 8 x 5
    ##   country       continent  year lifeExp food   
    ##   <fct>         <fct>     <int>   <dbl> <chr>  
    ## 1 Belgium       Europe     2002    78.3 waffle 
    ## 2 Belgium       Europe     2007    79.4 waffle 
    ## 3 Canada        Americas   2002    79.8 poutine
    ## 4 Canada        Americas   2007    80.7 poutine
    ## 5 Mexico        Americas   2002    74.9 <NA>   
    ## 6 Mexico        Americas   2007    76.2 <NA>   
    ## 7 United States Americas   2002    77.3 Twinkie
    ## 8 United States Americas   2007    78.2 Twinkie

Another way to use lookups is with a named character vector. However,
remember that factors are indexed by **INTEGERS** under the hood, so you
need to make sure that both character vectors really are of character
class\!\!\!

``` r
# Make a named character vector for foods
(food_vec <-setNames(food$food, food$country))
```

    ##       Belgium        Canada United States 
    ##      "waffle"     "poutine"     "Twinkie"

``` r
# Wrong way...using factors instead of characters
mini_gap %>% 
  mutate(food = food_vec[country])
```

    ## # A tibble: 8 x 5
    ##   country       continent  year lifeExp food   
    ##   <fct>         <fct>     <int>   <dbl> <chr>  
    ## 1 Belgium       Europe     2002    78.3 waffle 
    ## 2 Belgium       Europe     2007    79.4 waffle 
    ## 3 Canada        Americas   2002    79.8 poutine
    ## 4 Canada        Americas   2007    80.7 poutine
    ## 5 Mexico        Americas   2002    74.9 Twinkie
    ## 6 Mexico        Americas   2007    76.2 Twinkie
    ## 7 United States Americas   2002    77.3 <NA>   
    ## 8 United States Americas   2007    78.2 <NA>

``` r
  #Twinkie is NOT the national food of Mexico!!!

#Oh this is how the factors are represented under the hood!
  #it's just a coincidence that Belgium and Canada get the right foods
unclass(mini_gap$country)
```

    ## [1] 1 1 2 2 3 3 4 4
    ## attr(,"levels")
    ## [1] "Belgium"       "Canada"        "Mexico"        "United States"

``` r
#Correct way...cooerce country to a character class first.
mini_gap %>% 
  mutate(food = food_vec[as.character(country)])
```

    ## # A tibble: 8 x 5
    ##   country       continent  year lifeExp food   
    ##   <fct>         <fct>     <int>   <dbl> <chr>  
    ## 1 Belgium       Europe     2002    78.3 waffle 
    ## 2 Belgium       Europe     2007    79.4 waffle 
    ## 3 Canada        Americas   2002    79.8 poutine
    ## 4 Canada        Americas   2007    80.7 poutine
    ## 5 Mexico        Americas   2002    74.9 <NA>   
    ## 6 Mexico        Americas   2007    76.2 <NA>   
    ## 7 United States Americas   2002    77.3 Twinkie
    ## 8 United States Americas   2007    78.2 Twinkie
