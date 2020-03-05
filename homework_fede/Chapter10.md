Chapter 10 STAT545
================
Federico Andrade-Rivas
March 4, 2020

FACTORS
-------

### 10.4 Factor Inspection

``` r
str(gapminder$continent)
```

    ##  Factor w/ 5 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...

``` r
levels(gapminder$continent)
```

    ## [1] "Africa"   "Americas" "Asia"     "Europe"   "Oceania"

``` r
nlevels(gapminder$continent)
```

    ## [1] 5

``` r
class(gapminder$continent)
```

    ## [1] "factor"

``` r
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

``` r
gapminder %>% count(continent)
```

    ## # A tibble: 5 x 2
    ##   continent     n
    ##   <fct>     <int>
    ## 1 Africa      624
    ## 2 Americas    300
    ## 3 Asia        396
    ## 4 Europe      360
    ## 5 Oceania      24

### 10.5 Dropping unused levels

``` r
nlevels(gapminder$country)
```

    ## [1] 142

``` r
#Watch what happens to the levels of country (= nothing) when we filter Gapminder to a handful of countries.

h_countries <- c("Colombia", "Canada", "South Africa", "Ecuador", "Costa Rica", "Peru")
h_gap <- gapminder %>% filter(country %in% h_countries)
nlevels(h_gap$country)
```

    ## [1] 142

``` r
#Even though h_gap only has data for a handful of countries, we are still schlepping around all 142 levels from the original gapminder tibble.
```

Dropping levels using different strategies

``` r
h_gapdropped <- h_gap %>% droplevels()
nlevels(h_gapdropped$country)
```

    ## [1] 6

``` r
h_gap$country %>% fct_drop() %>% 
                  levels()
```

    ## [1] "Canada"       "Colombia"     "Costa Rica"   "Ecuador"      "Peru"        
    ## [6] "South Africa"

### Exercise 10.5. Filter the gapminder data down to rows where population is less than a quarter of a million, i.e. 250,000. Get rid of the unused factor levels for country and continent in different ways, such as:

``` r
nlevels(gapminder$country)
```

    ## [1] 142

``` r
nlevels(gapminder$continent)
```

    ## [1] 5

``` r
gap_Less1qrt <- gapminder %>% filter(pop < 250000) %>% 
                              droplevels()  

nlevels(gap_Less1qrt$country)
```

    ## [1] 7

``` r
nlevels(gap_Less1qrt$continent)            
```

    ## [1] 3

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
