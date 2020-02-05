Chapter7\_Fede
================
Federico Andrade-Rivas
January 29, 2020

Loading Libraries
-----------------

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✔ ggplot2 3.2.1     ✔ purrr   0.3.3
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ───────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(gapminder)
```

Create a copy of gapminder
--------------------------

``` r
library(gapminder)
my_gap <-gapminder
my_gap %>% filter(country == "Canada")  
```

    ## # A tibble: 12 x 6
    ##    country continent  year lifeExp      pop gdpPercap
    ##    <fct>   <fct>     <int>   <dbl>    <int>     <dbl>
    ##  1 Canada  Americas   1952    68.8 14785584    11367.
    ##  2 Canada  Americas   1957    70.0 17010154    12490.
    ##  3 Canada  Americas   1962    71.3 18985849    13462.
    ##  4 Canada  Americas   1967    72.1 20819767    16077.
    ##  5 Canada  Americas   1972    72.9 22284500    18971.
    ##  6 Canada  Americas   1977    74.2 23796400    22091.
    ##  7 Canada  Americas   1982    75.8 25201900    22899.
    ##  8 Canada  Americas   1987    76.9 26549700    26627.
    ##  9 Canada  Americas   1992    78.0 28523502    26343.
    ## 10 Canada  Americas   1997    78.6 30305843    28955.
    ## 11 Canada  Americas   2002    79.8 31902268    33329.
    ## 12 Canada  Americas   2007    80.7 33390141    36319.

``` r
#Storing the output as an object

my_precious <- my_gap %>% filter(country =="Canada")
```

``` r
 my_gap %>% mutate(gdp = pop*gdpPercap)
```

    ## # A tibble: 1,704 x 7
    ##    country     continent  year lifeExp      pop gdpPercap          gdp
    ##    <fct>       <fct>     <int>   <dbl>    <int>     <dbl>        <dbl>
    ##  1 Afghanistan Asia       1952    28.8  8425333      779.  6567086330.
    ##  2 Afghanistan Asia       1957    30.3  9240934      821.  7585448670.
    ##  3 Afghanistan Asia       1962    32.0 10267083      853.  8758855797.
    ##  4 Afghanistan Asia       1967    34.0 11537966      836.  9648014150.
    ##  5 Afghanistan Asia       1972    36.1 13079460      740.  9678553274.
    ##  6 Afghanistan Asia       1977    38.4 14880372      786. 11697659231.
    ##  7 Afghanistan Asia       1982    39.9 12881816      978. 12598563401.
    ##  8 Afghanistan Asia       1987    40.8 13867957      852. 11820990309.
    ##  9 Afghanistan Asia       1992    41.7 16317921      649. 10595901589.
    ## 10 Afghanistan Asia       1997    41.8 22227415      635. 14121995875.
    ## # … with 1,694 more rows

``` r
# Create a new variable that is gdpPercap divided by Canadian gdpPercap, taking care that I always divide two numbers that pertain to the same year

cgdp <- my_gap %>% filter(country =="Canada")

my_gap <- my_gap %>% mutate(temp = rep(cgdp$gdpPercap, nlevels(country)),
                            gdpRelaC = gdpPercap/temp,
                            temp = NULL
                            )
#Note: nlevels is used to create a variable that is as long as the number of levels per country. All countries have data for the same years. Otherwise this would not work 

my_gap %>%  filter(country == "Canada") %>% select(country, year, gdpPercap, gdpRelaC)
```

    ## # A tibble: 12 x 4
    ##    country  year gdpPercap gdpRelaC
    ##    <fct>   <int>     <dbl>    <dbl>
    ##  1 Canada   1952    11367.        1
    ##  2 Canada   1957    12490.        1
    ##  3 Canada   1962    13462.        1
    ##  4 Canada   1967    16077.        1
    ##  5 Canada   1972    18971.        1
    ##  6 Canada   1977    22091.        1
    ##  7 Canada   1982    22899.        1
    ##  8 Canada   1987    26627.        1
    ##  9 Canada   1992    26343.        1
    ## 10 Canada   1997    28955.        1
    ## 11 Canada   2002    33329.        1
    ## 12 Canada   2007    36319.        1

``` r
#Distribution of gdp related with the Canadian one

summary(my_gap$gdpRelaC)
```

    ##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
    ## 0.007236 0.061648 0.171521 0.326659 0.446564 9.534690

!!!!Remember: Trust No One. Including (especially?) yourself. Always try to find a way to check that you’ve done what meant to. Prepare to be horrified.
========================================================================================================================================================

Arrange function
----------------

``` r
#Use arrange() to row-order data in a principled way
#Example to arrange by year then country
my_gap %>% arrange(year, country)
```

    ## # A tibble: 1,704 x 7
    ##    country     continent  year lifeExp      pop gdpPercap gdpRelaC
    ##    <fct>       <fct>     <int>   <dbl>    <int>     <dbl>    <dbl>
    ##  1 Afghanistan Asia       1952    28.8  8425333      779.   0.0686
    ##  2 Albania     Europe     1952    55.2  1282697     1601.   0.141 
    ##  3 Algeria     Africa     1952    43.1  9279525     2449.   0.215 
    ##  4 Angola      Africa     1952    30.0  4232095     3521.   0.310 
    ##  5 Argentina   Americas   1952    62.5 17876956     5911.   0.520 
    ##  6 Australia   Oceania    1952    69.1  8691212    10040.   0.883 
    ##  7 Austria     Europe     1952    66.8  6927772     6137.   0.540 
    ##  8 Bahrain     Asia       1952    50.9   120447     9867.   0.868 
    ##  9 Bangladesh  Asia       1952    37.5 46886859      684.   0.0602
    ## 10 Belgium     Europe     1952    68    8730405     8343.   0.734 
    ## # … with 1,694 more rows

``` r
#Example to arrange by continent then country
my_gap %>% arrange(continent, country)
```

    ## # A tibble: 1,704 x 7
    ##    country continent  year lifeExp      pop gdpPercap gdpRelaC
    ##    <fct>   <fct>     <int>   <dbl>    <int>     <dbl>    <dbl>
    ##  1 Algeria Africa     1952    43.1  9279525     2449.    0.215
    ##  2 Algeria Africa     1957    45.7 10270856     3014.    0.241
    ##  3 Algeria Africa     1962    48.3 11000948     2551.    0.189
    ##  4 Algeria Africa     1967    51.4 12760499     3247.    0.202
    ##  5 Algeria Africa     1972    54.5 14760787     4183.    0.220
    ##  6 Algeria Africa     1977    58.0 17152804     4910.    0.222
    ##  7 Algeria Africa     1982    61.4 20033753     5745.    0.251
    ##  8 Algeria Africa     1987    65.8 23254956     5681.    0.213
    ##  9 Algeria Africa     1992    67.7 26298373     5023.    0.191
    ## 10 Algeria Africa     1997    69.2 29072015     4797.    0.166
    ## # … with 1,694 more rows

``` r
#example one year but sorted by life expectancy
 my_gap %>% filter(year == 1952) %>% arrange(gdpPercap) %>% select(country, continent, year, gdpPercap)
```

    ## # A tibble: 142 x 4
    ##    country           continent  year gdpPercap
    ##    <fct>             <fct>     <int>     <dbl>
    ##  1 Lesotho           Africa     1952      299.
    ##  2 Guinea-Bissau     Africa     1952      300.
    ##  3 Eritrea           Africa     1952      329.
    ##  4 Myanmar           Asia       1952      331 
    ##  5 Burundi           Africa     1952      339.
    ##  6 Ethiopia          Africa     1952      362.
    ##  7 Cambodia          Asia       1952      368.
    ##  8 Malawi            Africa     1952      369.
    ##  9 Equatorial Guinea Africa     1952      376.
    ## 10 China             Asia       1952      400.
    ## # … with 132 more rows

``` r
 #NOw in descending order for 2007
 
 my_gap %>% filter(year == 2007) %>% arrange(desc(gdpPercap)) %>% select(country, continent, year, gdpPercap)
```

    ## # A tibble: 142 x 4
    ##    country          continent  year gdpPercap
    ##    <fct>            <fct>     <int>     <dbl>
    ##  1 Norway           Europe     2007    49357.
    ##  2 Kuwait           Asia       2007    47307.
    ##  3 Singapore        Asia       2007    47143.
    ##  4 United States    Americas   2007    42952.
    ##  5 Ireland          Europe     2007    40676.
    ##  6 Hong Kong, China Asia       2007    39725.
    ##  7 Switzerland      Europe     2007    37506.
    ##  8 Netherlands      Europe     2007    36798.
    ##  9 Canada           Americas   2007    36319.
    ## 10 Iceland          Europe     2007    36181.
    ## # … with 132 more rows

``` r
 #"I advise that your analyses NEVER rely on rows or variables being in a specific order. But it’s still true that human beings write the code and the interactive development process can be much nicer if you reorder the rows of your data as you go along. Also, once you are preparing tables for human eyeballs, it is imperative that you step up and take control of row order."
```

Rename, Select, and Group by
----------------------------

``` r
#camelCase Vs snake_case
#Rename variables (not assigning!)

my_gap %>% rename(life_exp = lifeExp,
                  gdp_percap = gdpPercap,
                  gdp_percap_rel = gdpRelaC)
```

    ## # A tibble: 1,704 x 7
    ##    country     continent  year life_exp      pop gdp_percap gdp_percap_rel
    ##    <fct>       <fct>     <int>    <dbl>    <int>      <dbl>          <dbl>
    ##  1 Afghanistan Asia       1952     28.8  8425333       779.         0.0686
    ##  2 Afghanistan Asia       1957     30.3  9240934       821.         0.0657
    ##  3 Afghanistan Asia       1962     32.0 10267083       853.         0.0634
    ##  4 Afghanistan Asia       1967     34.0 11537966       836.         0.0520
    ##  5 Afghanistan Asia       1972     36.1 13079460       740.         0.0390
    ##  6 Afghanistan Asia       1977     38.4 14880372       786.         0.0356
    ##  7 Afghanistan Asia       1982     39.9 12881816       978.         0.0427
    ##  8 Afghanistan Asia       1987     40.8 13867957       852.         0.0320
    ##  9 Afghanistan Asia       1992     41.7 16317921       649.         0.0246
    ## 10 Afghanistan Asia       1997     41.8 22227415       635.         0.0219
    ## # … with 1,694 more rows

``` r
#select can rename and reposition 
#select() can rename the variables you request to keep.
#select() can be used with everything() to hoist a variable up to the front of the tibble.

my_gap %>% 
  filter(country == "Burundi", year > 1996) %>% 
  select(yr = year, life_exp = lifeExp, gdp_Percap = gdpPercap) %>% 
  select(gdp_Percap, everything())
```

    ## # A tibble: 3 x 3
    ##   gdp_Percap    yr life_exp
    ##        <dbl> <int>    <dbl>
    ## 1       463.  1997     45.3
    ## 2       446.  2002     47.4
    ## 3       430.  2007     49.6

``` r
#Counting things up

my_gap %>% 
  group_by(continent) %>% 
  summarize(n = n())
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
#Same info as R base table() but issues with computing

table(my_gap$continent)
```

    ## 
    ##   Africa Americas     Asia   Europe  Oceania 
    ##      624      300      396      360       24

``` r
#tally() counts rows

my_gap %>% 
  group_by(continent) %>% 
  tally()
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
#The count() function is an even more convenient function that does both grouping and counting.

my_gap %>% 
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
#Use the n_distinct() function to count the number of distinct countries within each continent.

my_gap %>% 
  group_by(continent) %>% 
  summarize(n = n(),
            n_countries = n_distinct(country))
```

    ## # A tibble: 5 x 3
    ##   continent     n n_countries
    ##   <fct>     <int>       <int>
    ## 1 Africa      624          52
    ## 2 Americas    300          25
    ## 3 Asia        396          33
    ## 4 Europe      360          30
    ## 5 Oceania      24           2

``` r
#general summarization
my_gap %>% 
  group_by(continent) %>% 
  summarize(avg_lifeExp = mean(lifeExp))
```

    ## # A tibble: 5 x 2
    ##   continent avg_lifeExp
    ##   <fct>           <dbl>
    ## 1 Africa           48.9
    ## 2 Americas         64.7
    ## 3 Asia             60.1
    ## 4 Europe           71.9
    ## 5 Oceania          74.3

``` r
#using summarize at (applies several functions)

my_gap %>% 
  filter(year %in% c(1952,2007)) %>% 
  group_by(continent, year) %>% 
  summarize_at(vars(lifeExp,gdpPercap), list(~mean(.), ~median(.), ~sd(.)))
```

    ## # A tibble: 10 x 8
    ## # Groups:   continent [5]
    ##    continent  year lifeExp_mean gdpPercap_mean lifeExp_median gdpPercap_median
    ##    <fct>     <int>        <dbl>          <dbl>          <dbl>            <dbl>
    ##  1 Africa     1952         39.1          1253.           38.8             987.
    ##  2 Africa     2007         54.8          3089.           52.9            1452.
    ##  3 Americas   1952         53.3          4079.           54.7            3048.
    ##  4 Americas   2007         73.6         11003.           72.9            8948.
    ##  5 Asia       1952         46.3          5195.           44.9            1207.
    ##  6 Asia       2007         70.7         12473.           72.4            4471.
    ##  7 Europe     1952         64.4          5661.           65.9            5142.
    ##  8 Europe     2007         77.6         25054.           78.6           28054.
    ##  9 Oceania    1952         69.3         10298.           69.3           10298.
    ## 10 Oceania    2007         80.7         29810.           80.7           29810.
    ## # … with 2 more variables: lifeExp_sd <dbl>, gdpPercap_sd <dbl>

``` r
# Minimun and maximun lifeExp seen by year. In Asia

my_gap %>% 
  filter(continent == "Asia") %>% 
  group_by(year) %>% 
  summarize(lifeExpmin = min(lifeExp), lifeExpmax = max(lifeExp))
```

    ## # A tibble: 12 x 3
    ##     year lifeExpmin lifeExpmax
    ##    <int>      <dbl>      <dbl>
    ##  1  1952       28.8       65.4
    ##  2  1957       30.3       67.8
    ##  3  1962       32.0       69.4
    ##  4  1967       34.0       71.4
    ##  5  1972       36.1       73.4
    ##  6  1977       31.2       75.4
    ##  7  1982       39.9       77.1
    ##  8  1987       40.8       78.7
    ##  9  1992       41.7       79.4
    ## 10  1997       41.8       80.7
    ## 11  2002       42.1       82  
    ## 12  2007       43.8       82.6

GROUP MUTATE
------------

``` r
#computing with group-wise summaries
#EXample, year of life exp gained relative to 1952 per country.

my_gap %>% 
  group_by(country) %>% 
  select(country, year, lifeExp) %>% 
  mutate(lifeExp_gain = lifeExp - first(lifeExp)) %>% 
  filter(year < 1963, year > 1952)
```

    ## # A tibble: 284 x 4
    ## # Groups:   country [142]
    ##    country      year lifeExp lifeExp_gain
    ##    <fct>       <int>   <dbl>        <dbl>
    ##  1 Afghanistan  1957    30.3         1.53
    ##  2 Afghanistan  1962    32.0         3.20
    ##  3 Albania      1957    59.3         4.05
    ##  4 Albania      1962    64.8         9.59
    ##  5 Algeria      1957    45.7         2.61
    ##  6 Algeria      1962    48.3         5.23
    ##  7 Angola       1957    32.0         1.98
    ##  8 Angola       1962    34           3.98
    ##  9 Argentina    1957    64.4         1.91
    ## 10 Argentina    1962    65.1         2.66
    ## # … with 274 more rows

``` r
#Windows functions
#ASi worst and best in Life exp, but retaining infor countries

my_gap %>% 
  filter(continent =="Asia") %>% 
  select(year, country, lifeExp) %>%   
  group_by(year) %>% 
  filter(min_rank(desc(lifeExp)) < 2 | min_rank(lifeExp) < 2) %>% 
    arrange(year) %>% 
    print(n=Inf)
```

    ## # A tibble: 24 x 3
    ## # Groups:   year [12]
    ##     year country     lifeExp
    ##    <int> <fct>         <dbl>
    ##  1  1952 Afghanistan    28.8
    ##  2  1952 Israel         65.4
    ##  3  1957 Afghanistan    30.3
    ##  4  1957 Israel         67.8
    ##  5  1962 Afghanistan    32.0
    ##  6  1962 Israel         69.4
    ##  7  1967 Afghanistan    34.0
    ##  8  1967 Japan          71.4
    ##  9  1972 Afghanistan    36.1
    ## 10  1972 Japan          73.4
    ## 11  1977 Cambodia       31.2
    ## 12  1977 Japan          75.4
    ## 13  1982 Afghanistan    39.9
    ## 14  1982 Japan          77.1
    ## 15  1987 Afghanistan    40.8
    ## 16  1987 Japan          78.7
    ## 17  1992 Afghanistan    41.7
    ## 18  1992 Japan          79.4
    ## 19  1997 Afghanistan    41.8
    ## 20  1997 Japan          80.7
    ## 21  2002 Afghanistan    42.1
    ## 22  2002 Japan          82  
    ## 23  2007 Afghanistan    43.8
    ## 24  2007 Japan          82.6

``` r
#Sharpest drop lifeExp in 5 years , By continent

my_gap %>% 
  select(country, year, continent, lifeExp) %>% 
  group_by(continent, country) %>%
  ## within country, take (lifeExp in year i) - (lifeExp in year i - 1)
  ## positive means lifeExp went up, negative means it went down
  mutate(le_delta = lifeExp - lag(lifeExp)) %>% 
  ## within country, retain the worst lifeExp change = smallest or most negative
  summarize(worst_le_delta = min(le_delta, na.rm =TRUE)) %>% 
  ## within continent, retain the row with the lowest worst_le_delta
   #In this case the top(-2) indicates to take two min values of the variable. 
  top_n(-2, wt = worst_le_delta) %>% 
arrange(worst_le_delta)
```

    ## # A tibble: 10 x 3
    ## # Groups:   continent [5]
    ##    continent country     worst_le_delta
    ##    <fct>     <fct>                <dbl>
    ##  1 Africa    Rwanda             -20.4  
    ##  2 Africa    Zimbabwe           -13.6  
    ##  3 Asia      Cambodia            -9.10 
    ##  4 Asia      China               -6.05 
    ##  5 Americas  El Salvador         -1.51 
    ##  6 Europe    Montenegro          -1.46 
    ##  7 Europe    Bulgaria            -0.87 
    ##  8 Americas  Puerto Rico         -0.719
    ##  9 Oceania   Australia            0.170
    ## 10 Oceania   New Zealand          0.28

![](Chapter7_files/figure-markdown_github/pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
