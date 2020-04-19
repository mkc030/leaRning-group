Chapter 14, 15, 16
================
Federico Andrade-Rivas
April 3, 2020

``` r
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✔ ggplot2 3.2.1     ✔ purrr   0.3.3
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

*But what if your data arrives in many pieces? There are many good (and bad) reasons why this might happen. How do you get it into one big beautiful tibble? These tasks break down into 3 main classes*:

*Bind *Join \*Lookup

#### 14.1 Typology of data combination tasks

*Bind ---&gt; Like smashing rocks! Be careful *Join ----&gt; Using a key variable to join \*Lookup ----&gt; special case of 'join'

#### 14.1 Typology of data combination tasks

``` r
fship <- tribble(
                         ~Film,    ~Race, ~Female, ~Male,
  "The Fellowship Of The Ring",    "Elf",    1229,   971,
  "The Fellowship Of The Ring", "Hobbit",      14,  3644,
  "The Fellowship Of The Ring",    "Man",       0,  1995
)
rking <- tribble(
                         ~Film,    ~Race, ~Female, ~Male,
      "The Return Of The King",    "Elf",     183,   510,
      "The Return Of The King", "Hobbit",       2,  2673,
      "The Return Of The King",    "Man",     268,  2459
)
ttow <- tribble(
                         ~Film,    ~Race, ~Female, ~Male,
              "The Two Towers",    "Elf",     331,   513,
              "The Two Towers", "Hobbit",       0,  2463,
              "The Two Towers",    "Man",     401,  3589
)
(lotr_untidy <- bind_rows(fship, ttow, rking))
```

    ## # A tibble: 9 x 4
    ##   Film                       Race   Female  Male
    ##   <chr>                      <chr>   <dbl> <dbl>
    ## 1 The Fellowship Of The Ring Elf      1229   971
    ## 2 The Fellowship Of The Ring Hobbit     14  3644
    ## 3 The Fellowship Of The Ring Man         0  1995
    ## 4 The Two Towers             Elf       331   513
    ## 5 The Two Towers             Hobbit      0  2463
    ## 6 The Two Towers             Man       401  3589
    ## 7 The Return Of The King     Elf       183   510
    ## 8 The Return Of The King     Hobbit      2  2673
    ## 9 The Return Of The King     Man       268  2459

``` r
lotr_untidy2 <- rbind(fship, ttow, rking)
lotr_untidy2
```

    ## # A tibble: 9 x 4
    ##   Film                       Race   Female  Male
    ##   <chr>                      <chr>   <dbl> <dbl>
    ## 1 The Fellowship Of The Ring Elf      1229   971
    ## 2 The Fellowship Of The Ring Hobbit     14  3644
    ## 3 The Fellowship Of The Ring Man         0  1995
    ## 4 The Two Towers             Elf       331   513
    ## 5 The Two Towers             Hobbit      0  2463
    ## 6 The Two Towers             Man       401  3589
    ## 7 The Return Of The King     Elf       183   510
    ## 8 The Return Of The King     Hobbit      2  2673
    ## 9 The Return Of The King     Man       268  2459

But what if one of the data frames is somehow missing a variable? Let’s mangle one and find out.

We see that dplyr::bind\_rows() does the row bind and puts NA in for the missing values caused by the lack of Female data from The Two Towers. Base rbind() refuses to row bind in this situation.

``` r
ttow_no_Female <- ttow %>% mutate(Female = NULL)
bind_rows(fship, ttow_no_Female, rking)
```

    ## # A tibble: 9 x 4
    ##   Film                       Race   Female  Male
    ##   <chr>                      <chr>   <dbl> <dbl>
    ## 1 The Fellowship Of The Ring Elf      1229   971
    ## 2 The Fellowship Of The Ring Hobbit     14  3644
    ## 3 The Fellowship Of The Ring Man         0  1995
    ## 4 The Two Towers             Elf        NA   513
    ## 5 The Two Towers             Hobbit     NA  2463
    ## 6 The Two Towers             Man        NA  3589
    ## 7 The Return Of The King     Elf       183   510
    ## 8 The Return Of The King     Hobbit      2  2673
    ## 9 The Return Of The King     Man       268  2459

``` r
#rbind(fship, ttow_no_Female, rking)
```

In conclusion, row binding usually works when it should (especially with dplyr::bind\_rows()) and usually doesn’t when it shouldn’t. The biggest risk is being aggravated.

###### 14.2.2 Column binding

Column binding is much more dangerous because it often “works” when it should not. It’s your job to the rows are aligned and it’s all too easy to screw this up.

The data in gapminder was originally excavated from 3 messy Excel spreadsheets: one each for life expectancy, population, and GDP per capital. Let’s relive some of the data wrangling joy and show a column bind gone wrong.

I create 3 separate data frames, do some evil row sorting, then column bind. There are no errors. The result gapminder\_garbage sort of looks OK. Univariate summary statistics and exploratory plots will look OK. But I’ve created complete nonsense!

``` r
library(gapminder)

life_exp <- gapminder %>%
  select(country, year, lifeExp)

pop <- gapminder %>%
  arrange(year) %>% 
  select(pop)
  
gdp_percap <- gapminder %>% 
  arrange(pop) %>% 
  select(gdpPercap)

(gapminder_garbage <- bind_cols(life_exp, pop, gdp_percap))
```

    ## # A tibble: 1,704 x 5
    ##    country      year lifeExp      pop gdpPercap
    ##    <fct>       <int>   <dbl>    <int>     <dbl>
    ##  1 Afghanistan  1952    28.8  8425333      880.
    ##  2 Afghanistan  1957    30.3  1282697      861.
    ##  3 Afghanistan  1962    32.0  9279525     2670.
    ##  4 Afghanistan  1967    34.0  4232095     1072.
    ##  5 Afghanistan  1972    36.1 17876956     1385.
    ##  6 Afghanistan  1977    38.4  8691212     2865.
    ##  7 Afghanistan  1982    39.9  6927772     1533.
    ##  8 Afghanistan  1987    40.8   120447     1738.
    ##  9 Afghanistan  1992    41.7 46886859     3021.
    ## 10 Afghanistan  1997    41.8  8730405     1890.
    ## # … with 1,694 more rows

``` r
summary(gapminder$lifeExp)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   23.60   48.20   60.71   59.47   70.85   82.60

``` r
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    23.6    48.2    60.7    59.5    70.8    82.6
summary(gapminder_garbage$lifeExp)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   23.60   48.20   60.71   59.47   70.85   82.60

``` r
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    23.6    48.2    60.7    59.5    70.8    82.6
range(gapminder$gdpPercap)
```

    ## [1]    241.1659 113523.1329

``` r
#> [1]    241 113523
range(gapminder_garbage$gdpPercap)
```

    ## [1]    241.1659 113523.1329

``` r
#> [1]    241 113523
```

NOTE: BEcasue variables are arranged in different ways, variables do not correspond to the country and tdate. Summary stats will still look OK.... dangerous

One last cautionary tale about column binding. This one requires the use of cbind() and it’s why the tidyverse is generally unwilling to recycle when combining things of different length.

I create a tibble with most of the gapminder columns. I create another with the remainder, but filtered down to just one country. I am able to cbind() these objects! Why? Because the 12 rows for Canada divide evenly into the 1704 rows of gapminder. Note that dplyr::bind\_cols() refuses to column bind here.

``` r
gapminder_mostly <- gapminder %>% select(-pop, -gdpPercap)
gapminder_leftovers_filtered <- gapminder %>% 
  filter(country == "Canada") %>% 
  select(pop, gdpPercap)

gapminder_nonsense <- cbind(gapminder_mostly, gapminder_leftovers_filtered)
head(gapminder_nonsense, 14)
```

    ##        country continent year lifeExp      pop gdpPercap
    ## 1  Afghanistan      Asia 1952  28.801 14785584  11367.16
    ## 2  Afghanistan      Asia 1957  30.332 17010154  12489.95
    ## 3  Afghanistan      Asia 1962  31.997 18985849  13462.49
    ## 4  Afghanistan      Asia 1967  34.020 20819767  16076.59
    ## 5  Afghanistan      Asia 1972  36.088 22284500  18970.57
    ## 6  Afghanistan      Asia 1977  38.438 23796400  22090.88
    ## 7  Afghanistan      Asia 1982  39.854 25201900  22898.79
    ## 8  Afghanistan      Asia 1987  40.822 26549700  26626.52
    ## 9  Afghanistan      Asia 1992  41.674 28523502  26342.88
    ## 10 Afghanistan      Asia 1997  41.763 30305843  28954.93
    ## 11 Afghanistan      Asia 2002  42.129 31902268  33328.97
    ## 12 Afghanistan      Asia 2007  43.828 33390141  36319.24
    ## 13     Albania    Europe 1952  55.230 14785584  11367.16
    ## 14     Albania    Europe 1957  59.280 17010154  12489.95

This data frame isn’t obviously wrong, but it is wrong. See how the Canada’s population and GDP per capita repeat for each country?

Bottom line: Row bind when you need to, but inspect the results re: coercion. Column bind only if you must and be extremely paranoid.

Chapter 15
----------

The data

``` r
superheroes <- tibble::tribble(
       ~name, ~alignment,  ~gender,          ~publisher,
   "Magneto",      "bad",   "male",            "Marvel",
     "Storm",     "good", "female",            "Marvel",
  "Mystique",      "bad", "female",            "Marvel",
    "Batman",     "good",   "male",                "DC",
     "Joker",      "bad",   "male",                "DC",
  "Catwoman",      "bad", "female",                "DC",
   "Hellboy",     "good",   "male", "Dark Horse Comics"
  )

publishers <- tibble::tribble(
  ~publisher, ~yr_founded,
        "DC",       1934L,
    "Marvel",       1939L,
     "Image",       1992L
  )
```

inner\_join(x, y): Return all rows from x where there are matching values in y, and all columns from x and y. If there are multiple matches between x and y, all combination of the matches are returned. This is a mutating join.

``` r
ijsp <- inner_join(superheroes, publishers)
```

    ## Joining, by = "publisher"

``` r
ijsp
```

    ## # A tibble: 6 x 5
    ##   name     alignment gender publisher yr_founded
    ##   <chr>    <chr>     <chr>  <chr>          <int>
    ## 1 Magneto  bad       male   Marvel          1939
    ## 2 Storm    good      female Marvel          1939
    ## 3 Mystique bad       female Marvel          1939
    ## 4 Batman   good      male   DC              1934
    ## 5 Joker    bad       male   DC              1934
    ## 6 Catwoman bad       female DC              1934

We lose Hellboy in the join because, although he appears in x = superheroes, his publisher Dark Horse Comics does not appear in y = publishers. The join result has all variables from x = superheroes plus yr\_founded, from y.

#### 15.4 semi\_join(superheroes, publishers)

semi\_join(x, y): Return all rows from x where there are matching values in y, keeping just columns from x. A semi join differs from an inner join because an inner join will return one row of x for each matching row of y, where a semi join will never duplicate rows of x. This is a filtering join. NOTE: If I put the funciont within () then it print it after it without needing to call it after.

``` r
(sjsp <- semi_join(superheroes, publishers))
```

    ## Joining, by = "publisher"

    ## # A tibble: 6 x 4
    ##   name     alignment gender publisher
    ##   <chr>    <chr>     <chr>  <chr>    
    ## 1 Magneto  bad       male   Marvel   
    ## 2 Storm    good      female Marvel   
    ## 3 Mystique bad       female Marvel   
    ## 4 Batman   good      male   DC       
    ## 5 Joker    bad       male   DC       
    ## 6 Catwoman bad       female DC

We get a similar result as with inner\_join() but the join result contains only the variables originally found in x = superheroes. NOTE: YEAR I THEN MISSING FROM THE RESULT TIBBLE

#### 15.5 left\_join(superheroes, publishers)

left\_join(x, y): Return all rows from x, and all columns from x and y. If there are multiple matches between x and y, all combination of the matches are returned. This is a mutating join.

``` r
(ljsp <- left_join (superheroes, publishers))
```

    ## Joining, by = "publisher"

    ## # A tibble: 7 x 5
    ##   name     alignment gender publisher         yr_founded
    ##   <chr>    <chr>     <chr>  <chr>                  <int>
    ## 1 Magneto  bad       male   Marvel                  1939
    ## 2 Storm    good      female Marvel                  1939
    ## 3 Mystique bad       female Marvel                  1939
    ## 4 Batman   good      male   DC                      1934
    ## 5 Joker    bad       male   DC                      1934
    ## 6 Catwoman bad       female DC                      1934
    ## 7 Hellboy  good      male   Dark Horse Comics         NA

We basically get x = superheroes back, but with the addition of variable yr\_founded, which is unique to y = publishers. Hellboy, whose publisher does not appear in y = publishers, has an NA for yr\_founded.

#### 15.6 anti\_join(superheroes, publishers)

anti\_join(x, y): Return all rows from x where there are not matching values in y, keeping just columns from x. This is a filtering join.

``` r
(ajsp <- anti_join(superheroes, publishers))
```

    ## Joining, by = "publisher"

    ## # A tibble: 1 x 4
    ##   name    alignment gender publisher        
    ##   <chr>   <chr>     <chr>  <chr>            
    ## 1 Hellboy good      male   Dark Horse Comics

#### 15.7 inner\_join(publishers, superheroes)

inner\_join(x, y): Return all rows from x where there are matching values in y, and all columns from x and y. If there are multiple matches between x and y, all combination of the matches are returned. This is a mutating join.

``` r
(ijps <- inner_join(publishers, superheroes))
```

    ## Joining, by = "publisher"

    ## # A tibble: 6 x 5
    ##   publisher yr_founded name     alignment gender
    ##   <chr>          <int> <chr>    <chr>     <chr> 
    ## 1 DC              1934 Batman   good      male  
    ## 2 DC              1934 Joker    bad       male  
    ## 3 DC              1934 Catwoman bad       female
    ## 4 Marvel          1939 Magneto  bad       male  
    ## 5 Marvel          1939 Storm    good      female
    ## 6 Marvel          1939 Mystique bad       female

In a way, this does illustrate multiple matches, if you think about it from the x = publishers direction. Every publisher that has a match in y = superheroes appears multiple times in the result, once for each match. In fact, we’re getting the same result as with inner\_join(superheroes, publishers), up to variable order (which you should also never rely on in an analysis).

#### 15.8 semi\_join(publishers, superheroes)

semi\_join(x, y): Return all rows from x where there are matching values in y, keeping just columns from x. A semi join differs from an inner join because an inner join will return one row of x for each matching row of y, where a semi join will never duplicate rows of x. This is a filtering join.

``` r
(sjps <- semi_join(x = publishers, y = superheroes))
```

    ## Joining, by = "publisher"

    ## # A tibble: 2 x 2
    ##   publisher yr_founded
    ##   <chr>          <int>
    ## 1 DC              1934
    ## 2 Marvel          1939

Now the effects of switching the x and y roles is more clear. The result resembles x = publishers, but the publisher Image is lost, because there are no observations where publisher == "Image" in y = superheroes.

#### 15.9 left\_join(publishers, superheroes)

left\_join(x, y): Return all rows from x, and all columns from x and y. If there are multiple matches between x and y, all combination of the matches are returned. This is a mutating join.

``` r
( ljps <- left_join (publishers, superheroes))
```

    ## Joining, by = "publisher"

    ## # A tibble: 7 x 5
    ##   publisher yr_founded name     alignment gender
    ##   <chr>          <int> <chr>    <chr>     <chr> 
    ## 1 DC              1934 Batman   good      male  
    ## 2 DC              1934 Joker    bad       male  
    ## 3 DC              1934 Catwoman bad       female
    ## 4 Marvel          1939 Magneto  bad       male  
    ## 5 Marvel          1939 Storm    good      female
    ## 6 Marvel          1939 Mystique bad       female
    ## 7 Image           1992 <NA>     <NA>      <NA>

We get a similar result as with inner\_join() but the publisher Image survives in the join, even though no superheroes from Image appear in y = superheroes. As a result, Image has NAs for name, alignment, and gender.\`

#### 15.10 anti\_join(publishers, superheroes)

anti\_join(x, y): Return all rows from x where there are not matching values in y, keeping just columns from x. This is a filtering join.

``` r
(ajps <- anti_join(publishers, superheroes))
```

    ## Joining, by = "publisher"

    ## # A tibble: 1 x 2
    ##   publisher yr_founded
    ##   <chr>          <int>
    ## 1 Image           1992

We keep only publisher Image now (and the variables found in x = publishers). NOTE: different selection of "x and y" than previous anti\_join example

##### 15.11 full\_join(superheroes, publishers)

full\_join(x, y): Return all rows and all columns from both x and y. Where there are not matching values, returns NA for the one missing. This is a mutating join.

``` r
(fjsp <- full_join(superheroes, publishers))
```

    ## Joining, by = "publisher"

    ## # A tibble: 8 x 5
    ##   name     alignment gender publisher         yr_founded
    ##   <chr>    <chr>     <chr>  <chr>                  <int>
    ## 1 Magneto  bad       male   Marvel                  1939
    ## 2 Storm    good      female Marvel                  1939
    ## 3 Mystique bad       female Marvel                  1939
    ## 4 Batman   good      male   DC                      1934
    ## 5 Joker    bad       male   DC                      1934
    ## 6 Catwoman bad       female DC                      1934
    ## 7 Hellboy  good      male   Dark Horse Comics         NA
    ## 8 <NA>     <NA>      <NA>   Image                   1992

We get all rows of x = superheroes plus a new row from y = publishers, containing the publisher Image. We get all variables from x = superheroes AND all variables from y = publishers. Any row that derives solely from one table or the other carries NAs in the variables found only in the other table.

16. Table lookup. Will not go through it. Does not seem I'll need it. Check in case you do so
---------------------------------------------------------------------------------------------
