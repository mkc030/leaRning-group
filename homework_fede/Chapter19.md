Chapter 19
================
Federico Andrade-Rivas
April 23, 2020

Chapter 19 Write your own R functions, part 2
---------------------------------------------

``` r
library(gapminder)

mmm <- function(x) {
  stopifnot(is.numeric(x))
  max(x) - min(x)
}
```

##### 19.5 Get something that works, again

The eventual inputs to our new function will be the data x and two probabilities.

First, play around with the quantile() function. Convince yourself you know how to use it, for example, by cross-checking your results with other built-in functions.

``` r
quantile(gapminder$lifeExp)
```

    ##      0%     25%     50%     75%    100% 
    ## 23.5990 48.1980 60.7125 70.8455 82.6030

``` r
quantile(gapminder$lifeExp, probs = 0.5)
```

    ##     50% 
    ## 60.7125

``` r
median(gapminder$lifeExp)
```

    ## [1] 60.7125

``` r
quantile(gapminder$lifeExp, probs = c(0.25, 0.75))
```

    ##     25%     75% 
    ## 48.1980 70.8455

``` r
boxplot(gapminder$lifeExp, plot = FALSE)$stats
```

    ##         [,1]
    ## [1,] 23.5990
    ## [2,] 48.1850
    ## [3,] 60.7125
    ## [4,] 70.8460
    ## [5,] 82.6030

Now write a code snippet that takes the difference between two quantiles.

``` r
the_probs <- c(0.25, 0.75)

the_quantiles <- quantile(gapminder$lifeExp, probs = the_probs)

max(the_quantiles) - min(the_quantiles)
```

    ## [1] 22.6475

#### 19.6 Turn the working interactive code into a function, again

I’ll use qdiff as the base of our function’s name. I copy the overall structure from our previous “max minus min” work but replace the guts of the function with the more general code we just developed.

``` r
qdiff1 <- function(x, probs) {
 stopifnot(is.numeric(x))
  the_quantiles <- quantile( x= x , probs = probs)
  max(the_quantiles) - min(the_quantiles)
}

qdiff1(gapminder$lifeExp, probs = c(0.25, 0.75))
```

    ## [1] 22.6475

``` r
IQR(gapminder$lifeExp)
```

    ## [1] 22.6475

``` r
qdiff1(gapminder$lifeExp, probs = c(0,1))
```

    ## [1] 59.004

``` r
mmm(gapminder$lifeExp)
```

    ## [1] 59.004

#### 19.8 What a function returns

By default, a function returns the result of the last line of the body. I am just letting that happen with the line max(the\_quantiles) - min(the\_quantiles). However, there is an explicit function for this: return(). I could just as easily make this the last line of my function’s body:

You absolutely must use return() if you want to return early based on some condition, i.e. before execution gets to the last line of the body. Otherwise, you can decide your own conventions about when you use return() and when you don’t.

#### 19.9 Default values: freedom to NOT specify the arguments

In our case, it would be crazy to specify a default value for the primary input x, but very kind to specify a default for probs.

We started by focusing on the max and the min, so I think those make reasonable defaults. Here’s how to specify that in a function definition.

``` r
qdiff3 <- function(x, probs = c(0,1)){
  stopifnot(is.numeric(x))
  the_quantiles <- quantile(x, probs)
  max(the_quantiles) - min(the_quantiles)
}
```

Again we check how the function works, in old examples and new, specifying the probs argument and not.

``` r
qdiff3(gapminder$lifeExp)
```

    ## [1] 59.004

``` r
mmm(gapminder$lifeExp)
```

    ## [1] 59.004

``` r
qdiff3(gapminder$lifeExp, c(0.1, 0.9))
```

    ## [1] 33.5862
