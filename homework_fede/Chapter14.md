Chapter 14
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
