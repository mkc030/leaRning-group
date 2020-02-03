Assignment 2
================

Exercise 1
----------

``` r
# 1.1 and 1.2
knitr::kable(
gapminder %>% 
  filter(country %in% c("Canada", "Japan", "Mexico"),
       year >= 1970 & year <= 1979) %>% 
  select(country, gdpPercap)
)
```

| country |  gdpPercap|
|:--------|----------:|
| Canada  |  18970.571|
| Canada  |  22090.883|
| Japan   |  14778.786|
| Japan   |  16610.377|
| Mexico  |   6809.407|
| Mexico  |   7674.929|

``` r
# 1.3
gapminder %>%
  group_by(country) %>% 
  mutate(le_delta = lifeExp - lag(lifeExp)) %>%
  filter(le_delta < 0)
```

    ## # A tibble: 102 x 7
    ## # Groups:   country [52]
    ##    country  continent  year lifeExp     pop gdpPercap le_delta
    ##    <fct>    <fct>     <int>   <dbl>   <int>     <dbl>    <dbl>
    ##  1 Albania  Europe     1992    71.6 3326498     2497.   -0.419
    ##  2 Angola   Africa     1987    39.9 7874230     2430.   -0.036
    ##  3 Benin    Africa     2002    54.4 7026113     1373.   -0.371
    ##  4 Botswana Africa     1992    62.7 1342614     7954.   -0.877
    ##  5 Botswana Africa     1997    52.6 1536536     8647.  -10.2  
    ##  6 Botswana Africa     2002    46.6 1630347    11004.   -5.92 
    ##  7 Bulgaria Europe     1977    70.8 8797022     7612.   -0.09 
    ##  8 Bulgaria Europe     1992    71.2 8658506     6303.   -0.15 
    ##  9 Bulgaria Europe     1997    70.3 8066057     5970.   -0.87 
    ## 10 Burundi  Africa     1992    44.7 5809236      632.   -3.48 
    ## # … with 92 more rows

``` r
# 1.4
gapminder %>%
  group_by(country) %>% 
  summarize(max_gdpPercap = max(gdpPercap, na.rm = TRUE)) %>% 
  arrange(desc(max_gdpPercap))
```

    ## # A tibble: 142 x 2
    ##    country          max_gdpPercap
    ##    <fct>                    <dbl>
    ##  1 Kuwait                 113523.
    ##  2 Norway                  49357.
    ##  3 Singapore               47143.
    ##  4 United States           42952.
    ##  5 Ireland                 40676.
    ##  6 Hong Kong, China        39725.
    ##  7 Switzerland             37506.
    ##  8 Netherlands             36798.
    ##  9 Canada                  36319.
    ## 10 Iceland                 36181.
    ## # … with 132 more rows

``` r
# 1.5
gapminder %>% 
  filter(country == "Canada") %>%
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
    geom_point() +
    scale_x_log10()
```

![](Assignment2_files/figure-markdown_github/exercise%201-1.png)

Exercise 2
----------

Categorical var = continent
Quantitative var = lifeExp

    ## [1] "Africa"   "Americas" "Asia"     "Europe"   "Oceania"

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   23.60   48.20   60.71   59.47   70.85   82.60

![](Assignment2_files/figure-markdown_github/exercise%202-1.png)

Exercise 3
----------

![](Assignment2_files/figure-markdown_github/exercise%20-1.png)

Recycling
---------

> filter(gapminder, country == c("Rwanda", "Afghanistan"))
> Not sure why this doesn't work
> It returns half of the values for each country -- years ending in 7 for Afghanistan and years ending in 2 for Rwanda
> It works if you pipe instead of concatinate although I don't know why
> filter(gapminder, country == "Rwanda" | country == "Afghanistan")
