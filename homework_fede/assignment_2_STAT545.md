Assignment 2 STAT 545
================
Federico Andrade-Rivas
February 5, 2020

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

``` r
library(gapminder)
```

Assignment 2
------------

#### 1.1 Use filter() to subset the gapminder data to three countries of your choice in the 1970’s.

``` r
mi_gap <- gapminder

mi_gap %>% filter(country == "Colombia"| country == "Venezuela"| country == "Ecuador", year >= 1970 & year <= 1978)
```

    ## # A tibble: 6 x 6
    ##   country   continent  year lifeExp      pop gdpPercap
    ##   <fct>     <fct>     <int>   <dbl>    <int>     <dbl>
    ## 1 Colombia  Americas   1972    61.6 22542890     3265.
    ## 2 Colombia  Americas   1977    63.8 25094412     3816.
    ## 3 Ecuador   Americas   1972    58.8  6298651     5281.
    ## 4 Ecuador   Americas   1977    61.3  7278866     6680.
    ## 5 Venezuela Americas   1972    65.7 11515649    10505.
    ## 6 Venezuela Americas   1977    67.5 13503563    13144.

``` r
mi_gap %>% filter(country %in% c("Colombia", "Venezuela", "Ecuador"), year %in% c(1972,1977))
```

    ## # A tibble: 6 x 6
    ##   country   continent  year lifeExp      pop gdpPercap
    ##   <fct>     <fct>     <int>   <dbl>    <int>     <dbl>
    ## 1 Colombia  Americas   1972    61.6 22542890     3265.
    ## 2 Colombia  Americas   1977    63.8 25094412     3816.
    ## 3 Ecuador   Americas   1972    58.8  6298651     5281.
    ## 4 Ecuador   Americas   1977    61.3  7278866     6680.
    ## 5 Venezuela Americas   1972    65.7 11515649    10505.
    ## 6 Venezuela Americas   1977    67.5 13503563    13144.

#### 1.2 Use filter() to subset the gapminder data to three countries of your choice in the 1970’s.

``` r
mi_gap %>% filter(country %in% c("Colombia", "Venezuela", "Ecuador"), year %in% c(1972,1977)) %>% 
  select(country, gdpPercap)
```

    ## # A tibble: 6 x 2
    ##   country   gdpPercap
    ##   <fct>         <dbl>
    ## 1 Colombia      3265.
    ## 2 Colombia      3816.
    ## 3 Ecuador       5281.
    ## 4 Ecuador       6680.
    ## 5 Venezuela    10505.
    ## 6 Venezuela    13144.

#### 1.3 Filter gapminder to all entries that have experienced a drop in life expectancy. Be sure to include a new variable that’s the increase in life expectancy in your tibble. Hint: you might find the lag() or diff() functions useful.

``` r
  mi_gap %>% select(continent, country, year, lifeExp) %>% 
  group_by(country) %>%  
  mutate(drop = lifeExp- lag(lifeExp)) %>% 
   filter(drop < 0)
```

    ## # A tibble: 102 x 5
    ## # Groups:   country [52]
    ##    continent country   year lifeExp    drop
    ##    <fct>     <fct>    <int>   <dbl>   <dbl>
    ##  1 Europe    Albania   1992    71.6  -0.419
    ##  2 Africa    Angola    1987    39.9  -0.036
    ##  3 Africa    Benin     2002    54.4  -0.371
    ##  4 Africa    Botswana  1992    62.7  -0.877
    ##  5 Africa    Botswana  1997    52.6 -10.2  
    ##  6 Africa    Botswana  2002    46.6  -5.92 
    ##  7 Europe    Bulgaria  1977    70.8  -0.09 
    ##  8 Europe    Bulgaria  1992    71.2  -0.15 
    ##  9 Europe    Bulgaria  1997    70.3  -0.87 
    ## 10 Africa    Burundi   1992    44.7  -3.48 
    ## # … with 92 more rows

``` r
#Not sure how to use it using diff()
```

#### 1.4a Filter gapminder so that it shows the max GDP per capita experienced by each country. Hint: you might find the max() function useful here

``` r
mi_gap %>% 
  group_by(country) %>% 
  summarize(maxGDP = max(gdpPercap))
```

    ## # A tibble: 142 x 2
    ##    country     maxGDP
    ##    <fct>        <dbl>
    ##  1 Afghanistan   978.
    ##  2 Albania      5937.
    ##  3 Algeria      6223.
    ##  4 Angola       5523.
    ##  5 Argentina   12779.
    ##  6 Australia   34435.
    ##  7 Austria     36126.
    ##  8 Bahrain     29796.
    ##  9 Bangladesh   1391.
    ## 10 Belgium     33693.
    ## # … with 132 more rows

``` r
 #Not sure how to keep the year!
```

#### 1.4b Filter gapminder to contain six rows: the rows with the three largest GDP per capita, and the rows with the three smallest GDP per capita. Be sure to not create any intermediate objects when doing this (with, for example, the assignment operator). Hint: you might find the sort() function useful, or perhaps even the dplyr::slice() function.

``` r
mi_gap %>% select(country, year, gdpPercap) %>% 
filter(min_rank(gdpPercap) <=3 | min_rank(desc(gdpPercap)) <=3) %>%                 
arrange(gdpPercap)  
```

    ## # A tibble: 6 x 3
    ##   country           year gdpPercap
    ##   <fct>            <int>     <dbl>
    ## 1 Congo, Dem. Rep.  2002      241.
    ## 2 Congo, Dem. Rep.  2007      278.
    ## 3 Lesotho           1952      299.
    ## 4 Kuwait            1952   108382.
    ## 5 Kuwait            1972   109348.
    ## 6 Kuwait            1957   113523.

Including Plots
---------------

You can also embed plots, for example:

![](assignment_2_STAT545_files/figure-markdown_github/pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
