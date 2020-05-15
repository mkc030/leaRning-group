Chapter18
================
Federico Andrade-Rivas
April 22, 2020

#### 18.2 Load the Gapminder data

``` r
library(gapminder)
str(gapminder)
```

    ## Classes 'tbl_df', 'tbl' and 'data.frame':    1704 obs. of  6 variables:
    ##  $ country  : Factor w/ 142 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ continent: Factor w/ 5 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...
    ##  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
    ##  $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
    ##  $ pop      : int  8425333 9240934 10267083 11537966 13079460 14880372 12881816 13867957 16317921 22227415 ...
    ##  $ gdpPercap: num  779 821 853 836 740 ...

Say you’ve got a numeric vector, and you want to compute the difference between its max and min. lifeExp or pop or gdpPercap are great examples of a typical input. You can imagine wanting to get this statistic after we slice up the Gapminder data by year, country, continent, or combinations thereof.

``` r
min(gapminder$lifeExp)
```

    ## [1] 23.599

``` r
max(gapminder$lifeExp)
```

    ## [1] 82.603

``` r
range(gapminder$lifeExp)
```

    ## [1] 23.599 82.603

``` r
## some natural solutions
max(gapminder$lifeExp) - min(gapminder$lifeExp)
```

    ## [1] 59.004

``` r
with(gapminder, max(lifeExp) - min(lifeExp))
```

    ## [1] 59.004

``` r
range(gapminder$lifeExp)[2] - range(gapminder$lifeExp)[1]
```

    ## [1] 59.004

``` r
with(gapminder, range(lifeExp)[2] - range(lifeExp)[1])
```

    ## [1] 59.004

``` r
diff(range(gapminder$lifeExp))
```

    ## [1] 59.004

#### 18.5 Turn the working interactive code into a function

Add NO new functionality! Just write your very first R function.

``` r
max_minus_min <- function(x) max(x) - min(x)

max_minus_min(gapminder$lifeExp)
```

    ## [1] 59.004

#### 18.6 Test your function

##### 18.6.1 Test on new inputs

Pick some new artificial inputs where you know (at least approximately) what your function should return.

``` r
max_minus_min(1:22)
```

    ## [1] 21

``` r
max_minus_min(runif(1000))
```

    ## [1] 0.9990752

##### 

18.6.2 Test on real data but different real data

``` r
max_minus_min(gapminder$pop)
```

    ## [1] 1318623085

``` r
max_minus_min(gapminder$gdpPercap)
```

    ## [1] 113282

#### 18.6.3 Test on weird stuff

Now we try to break our function. Don’t get truly diabolical (yet). Just make the kind of mistakes you can imagine making at 2am when, 3 years from now, you rediscover this useful function you wrote. Give your function inputs it’s not expecting.

``` r
#max_minus_min <- function(x) max(x) - min(x)

#max_minus_min(gapminder)

#max_minus_min(gapminder$continent)

#max_minus_min("hola")
```

##### 18.6.4 I will scare you now

``` r
max_minus_min(gapminder[c('lifeExp', 'gdpPercap', 'pop')])
```

    ## [1] 1318683072

``` r
max_minus_min(c(TRUE, TRUE, FALSE, TRUE, TRUE))
```

    ## [1] 1

#### 18.7 Check the validity of arguments

For functions that will be used again – which is not all of them! – it is good to check the validity of arguments. This implements a rule from the Unix philosophy:

-   Rule of Repair: When you must fail, fail noisily and as soon as possible.

#### 18.7.1 stop if not

stopifnot() is the entry level solution. I use it here to make sure the input x is a numeric vector.

``` r
mmm <- function(x) {
  stopifnot(is.numeric(x))
  max(x) - min(x)
}

#mmm(gapminder)

#mmm(gapminder$country)

#mmm(gapminder[c('lifeExp', 'gdpPercap', 'pop')])

#mmm(c(TRUE, TRUE, FALSE, TRUE, TRUE))
```
