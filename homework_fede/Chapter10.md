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
#using droplevels()
gap_Lessdrop <- gapminder %>% filter(pop < 250000) %>% 
                              droplevels()  
nlevels(gap_Lessdrop$country)
```

    ## [1] 7

``` r
nlevels(gap_Lessdrop$continent)            
```

    ## [1] 3

``` r
# using fct_drop() inside mutate() NOT WORKING

#gap_lessfct <- gapminder %>% mutate(countryless1qrt = pop < 250000, fct_drop(country)) %>% 
 #filter(countryless1qrt == TRUE) #%>% 
   #nlevels(gap_lessfct$country)
```

### Change order of the levels, principled

Order by frequency forward and backwards

``` r
gapminder$continent %>% levels() 
```

    ## [1] "Africa"   "Americas" "Asia"     "Europe"   "Oceania"

``` r
gapminder$continent %>% fct_infreq() %>% levels()
```

    ## [1] "Africa"   "Asia"     "Europe"   "Americas" "Oceania"

``` r
gapminder$continent %>% fct_infreq() %>% fct_rev() %>% levels()
```

    ## [1] "Oceania"  "Americas" "Europe"   "Asia"     "Africa"

Order country by other factor (The factor is the grouping variable and the default summarizing function is median() but you can specify something else.). Usse .desc for backwards

``` r
fct_reorder(gapminder$country, gapminder$lifeExp) %>% levels() %>% head() 
```

    ## [1] "Sierra Leone"  "Guinea-Bissau" "Afghanistan"   "Angola"       
    ## [5] "Somalia"       "Guinea"

``` r
fct_reorder(gapminder$country, gapminder$lifeExp, min) %>% levels() %>% head()
```

    ## [1] "Rwanda"       "Afghanistan"  "Gambia"       "Angola"       "Sierra Leone"
    ## [6] "Cambodia"

``` r
fct_reorder(gapminder$country, gapminder$lifeExp, median, .desc = TRUE) %>% levels() %>% head()
```

    ## [1] "Iceland"     "Japan"       "Sweden"      "Switzerland" "Netherlands"
    ## [6] "Norway"

![](Chapter10_files/figure-markdown_github/example%20plot-1.png)![](Chapter10_files/figure-markdown_github/example%20plot-2.png)

Use fct\_reorder2() when you have a line chart of a quantitative x against another quantitative y and your factor provides the color. This way the legend appears in some order as the data! Contrast the legend on the left with the one on the right.

![](Chapter10_files/figure-markdown_github/exampleplot-1.png)![](Chapter10_files/figure-markdown_github/exampleplot-2.png)

Change order of the levels, “because I said so”

``` r
h_gap$country %>% levels()
```

    ## [1] "Egypt"     "Haiti"     "Romania"   "Thailand"  "Venezuela"

``` r
h_gap$country %>% fct_relevel("Thailand", "Venezuela", "Romania") %>% levels()
```

    ## [1] "Thailand"  "Venezuela" "Romania"   "Egypt"     "Haiti"

Changing names of levels

``` r
i_gap <- gapminder %>% filter(country %in% c("Colombia", "Ecuador", "Chile", "Mexico", "Argentina")) %>% droplevels()

i_gap$country %>% fct_recode("Chimbchombianos" = "Colombia", "Merito" = "Mexico") %>% levels()
```

    ## [1] "Argentina"       "Chile"           "Chimbchombianos" "Ecuador"        
    ## [5] "Merito"

Exercise: Isolate the data for "Australia", "Korea, Dem. Rep.", and "Korea, Rep." in the 2000x. Revalue the country factor levels to "Oz", "North Korea", and "South Korea".

``` r
#i_gap <- gapminder %>% filter(country %in% c("Colombia", "Ecuador", "Chile", "Mexico", "Argentina")) %>% droplevels()

#i_gap$country %>% fct_recode("Chimbchombianos" = "Colombia", "Merito" = "Mexico") %>% levels()
```
