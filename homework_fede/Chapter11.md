Chapter 11
================
Federico Andrade-Rivas
March 17, 2020

Chapter 11 on VECTORS
---------------------

Here we discuss common remedial tasks for cleaning and transforming character data, also known as “strings”. A data frame or tibble will consist of one or more atomic vectors of a certain class. This lesson deals with things you can do with vectors of class character.

The stringr package is part of the core packages of the tidyverse. Main functions start with str\_. Auto-complete is your friend.

The chapter provides a lot of resources for different purposes, making it clear that it would only deal with the surface of the topic and when you find a particular issue, you should go to those resources.

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✔ ggplot2 3.2.1     ✔ purrr   0.3.3
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ───────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

#### Basic string manipulation tasks.

Detec or filter on a targeted string using str\_detect

``` r
#Detect how many fruits contain  the word fruit.

str_detect(fruit, pattern ="fruit")
```

    ##  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE
    ## [13] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
    ## [25] FALSE  TRUE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE FALSE
    ## [37] FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE FALSE FALSE FALSE FALSE
    ## [49] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE FALSE FALSE FALSE
    ## [61] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
    ## [73] FALSE FALSE  TRUE FALSE FALSE FALSE  TRUE FALSE

``` r
my_fruit <- str_subset(fruit, pattern = "fruit")
my_fruit
```

    ## [1] "breadfruit"   "dragonfruit"  "grapefruit"   "jackfruit"    "kiwi fruit"  
    ## [6] "passionfruit" "star fruit"   "ugli fruit"

You can use stringr to split strings on a delimiter that you can set. For example, in this case we can use the space between compuoun word to split them.

With str\_split you get a list in return. You can use str\_split to get a matrix with a fixed number of colums.

Also there is an alternative of using separate() if the variable is located in a data frame

``` r
my_fruit %>% str_split(pattern = " ")
```

    ## [[1]]
    ## [1] "breadfruit"
    ## 
    ## [[2]]
    ## [1] "dragonfruit"
    ## 
    ## [[3]]
    ## [1] "grapefruit"
    ## 
    ## [[4]]
    ## [1] "jackfruit"
    ## 
    ## [[5]]
    ## [1] "kiwi"  "fruit"
    ## 
    ## [[6]]
    ## [1] "passionfruit"
    ## 
    ## [[7]]
    ## [1] "star"  "fruit"
    ## 
    ## [[8]]
    ## [1] "ugli"  "fruit"

``` r
my_fruit %>% str_split_fixed(pattern = " ", n = 2)
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
my_fruit_df <- tibble(my_fruit)

my_fruit_df %>% separate(my_fruit, into = c("pre", "post"), sep = " " )
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

### 11.4.3 Substring extraction (and replacement) by position

You can count characters using str\_length. Using str\_sub() you can snip out substrings based on character position. A space is counted in the string length.

Note that the start and end arguments of str\_sub are vectorized (meaning that the position is not a fixed number but a vector)

Finally, str\_sub() also works for assignment, i.e. on the left hand side of &lt;-.

``` r
length(my_fruit)
```

    ## [1] 8

``` r
str_length(my_fruit)
```

    ## [1] 10 11 10  9 10 12 10 10

``` r
head(fruit) %>% str_sub(1,4)
```

    ## [1] "appl" "apri" "avoc" "bana" "bell" "bilb"

``` r
tibble(fruit) %>% head() %>% mutate(Snipped = str_sub(fruit, 1:6, 3:8))
```

    ## # A tibble: 6 x 2
    ##   fruit       Snipped
    ##   <chr>       <chr>  
    ## 1 apple       app    
    ## 2 apricot     pri    
    ## 3 avocado     oca    
    ## 4 banana      ana    
    ## 5 bell pepper " pe"  
    ## 6 bilberry    rry

``` r
x <- head(fruit,3)

str_sub(x, 1, 3) <- "AAA"
x
```

    ## [1] "AAAle"   "AAAicot" "AAAcado"
