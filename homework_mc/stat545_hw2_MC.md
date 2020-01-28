Stat 545 homework 2
================

## Load packages

    ## ── Attaching packages ───────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
    ## ✓ tibble  2.1.3     ✓ dplyr   0.8.3
    ## ✓ tidyr   1.0.0     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.4.0

    ## ── Conflicts ──────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

## Exercise 1 - Basic dplyr

``` r
# Examine the dataset to make sure it imported properly
glimpse(gapminder)
```

    ## Observations: 1,704
    ## Variables: 6
    ## $ country   <fct> Afghanistan, Afghanistan, Afghanistan, Afghanistan, Afghani…
    ## $ continent <fct> Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia,…
    ## $ year      <int> 1952, 1957, 1962, 1967, 1972, 1977, 1982, 1987, 1992, 1997,…
    ## $ lifeExp   <dbl> 28.801, 30.332, 31.997, 34.020, 36.088, 38.438, 39.854, 40.…
    ## $ pop       <int> 8425333, 9240934, 10267083, 11537966, 13079460, 14880372, 1…
    ## $ gdpPercap <dbl> 779.4453, 820.8530, 853.1007, 836.1971, 739.9811, 786.1134,…

``` r
head(gapminder)
```

    ## # A tibble: 6 x 6
    ##   country     continent  year lifeExp      pop gdpPercap
    ##   <fct>       <fct>     <int>   <dbl>    <int>     <dbl>
    ## 1 Afghanistan Asia       1952    28.8  8425333      779.
    ## 2 Afghanistan Asia       1957    30.3  9240934      821.
    ## 3 Afghanistan Asia       1962    32.0 10267083      853.
    ## 4 Afghanistan Asia       1967    34.0 11537966      836.
    ## 5 Afghanistan Asia       1972    36.1 13079460      740.
    ## 6 Afghanistan Asia       1977    38.4 14880372      786.

``` r
tail(gapminder)
```

    ## # A tibble: 6 x 6
    ##   country  continent  year lifeExp      pop gdpPercap
    ##   <fct>    <fct>     <int>   <dbl>    <int>     <dbl>
    ## 1 Zimbabwe Africa     1982    60.4  7636524      789.
    ## 2 Zimbabwe Africa     1987    62.4  9216418      706.
    ## 3 Zimbabwe Africa     1992    60.4 10704340      693.
    ## 4 Zimbabwe Africa     1997    46.8 11404948      792.
    ## 5 Zimbabwe Africa     2002    40.0 11926563      672.
    ## 6 Zimbabwe Africa     2007    43.5 12311143      470.

``` r
colSums(is.na(gapminder))
```

    ##   country continent      year   lifeExp       pop gdpPercap 
    ##         0         0         0         0         0         0

``` r
# 1.1 and 1.2 Filter down to year and countries of choice
gapminder %>% 
  filter(year >= 1970 & year <= 1979, 
         country == "Canada" | country == "Colombia" | country == "Cote d'Ivoire") %>%
  select(country, gdpPercap)
```

    ## # A tibble: 6 x 2
    ##   country       gdpPercap
    ##   <fct>             <dbl>
    ## 1 Canada           18971.
    ## 2 Canada           22091.
    ## 3 Colombia          3265.
    ## 4 Colombia          3816.
    ## 5 Cote d'Ivoire     2378.
    ## 6 Cote d'Ivoire     2518.

``` r
# 1.3 Drop in life expectancy
gapminder %>% 
  group_by(country) %>% 
  mutate(delta_life_exp = gdpPercap - lag(gdpPercap)) %>%
  filter(delta_life_exp < 0) 
```

    ## # A tibble: 332 x 7
    ## # Groups:   country [115]
    ##    country     continent  year lifeExp      pop gdpPercap delta_life_exp
    ##    <fct>       <fct>     <int>   <dbl>    <int>     <dbl>          <dbl>
    ##  1 Afghanistan Asia       1967    34.0 11537966      836.          -16.9
    ##  2 Afghanistan Asia       1972    36.1 13079460      740.          -96.2
    ##  3 Afghanistan Asia       1987    40.8 13867957      852.         -126. 
    ##  4 Afghanistan Asia       1992    41.7 16317921      649.         -203. 
    ##  5 Afghanistan Asia       1997    41.8 22227415      635.          -14.0
    ##  6 Albania     Europe     1992    71.6  3326498     2497.        -1241. 
    ##  7 Algeria     Africa     1962    48.3 11000948     2551.         -463. 
    ##  8 Algeria     Africa     1987    65.8 23254956     5681.          -63.8
    ##  9 Algeria     Africa     1992    67.7 26298373     5023.         -658. 
    ## 10 Algeria     Africa     1997    69.2 29072015     4797.         -226. 
    ## # … with 322 more rows

``` r
# Note that Dplyr functions automatically removes NAs and don't accept the na.rm argument

# 1.4a Max GDP per country
gapminder %>% 
  group_by(country) %>% 
  summarize(max_gdp = max(gdpPercap))
```

    ## # A tibble: 142 x 2
    ##    country     max_gdp
    ##    <fct>         <dbl>
    ##  1 Afghanistan    978.
    ##  2 Albania       5937.
    ##  3 Algeria       6223.
    ##  4 Angola        5523.
    ##  5 Argentina    12779.
    ##  6 Australia    34435.
    ##  7 Austria      36126.
    ##  8 Bahrain      29796.
    ##  9 Bangladesh    1391.
    ## 10 Belgium      33693.
    ## # … with 132 more rows

``` r
# 1.4b Three countries with the largest GPD and lowest GDP
gapminder %>% 
  group_by(country) %>% 
  summarise(max_gdp = max(gdpPercap)) %>% 
  filter(min_rank(max_gdp) <= 3 | min_rank(desc(max_gdp)) <= 3) %>% 
  arrange(max_gdp)
```

    ## # A tibble: 6 x 2
    ##   country   max_gdp
    ##   <fct>       <dbl>
    ## 1 Burundi      632.
    ## 2 Ethiopia     691.
    ## 3 Malawi       759.
    ## 4 Singapore  47143.
    ## 5 Norway     49357.
    ## 6 Kuwait    113523.

``` r
# 1.5 Scatterplot of Canada life expectancy vs GDP
gapminder %>% 
  filter(country == "Canada") %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
    geom_point() +
    scale_x_log10()
```

![](stat545_hw2_MC_files/figure-gfm/exercise%201-1.png)<!-- -->
