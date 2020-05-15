Chapter 17
================
Federico Andrade-Rivas
April 21, 2020

#### 17.1 Vectors are everywhere

Square brackets are used for isolating elements of a vector for inspection, modification, etc. This is often called indexing. BTW, indexing begins at 1 in R, unlike many other languages that index from 0.

``` r
 x <- 3 * 4
x
```

    ## [1] 12

``` r
is.vector(x)
```

    ## [1] TRUE

``` r
length(x)
```

    ## [1] 1

``` r
x[2] <- 100
x
```

    ## [1]  12 100

``` r
(x[5] <- 3)
```

    ## [1] 3

``` r
x
```

    ## [1]  12 100  NA  NA   3

``` r
x[11]
```

    ## [1] NA

``` r
x[0]
```

    ## numeric(0)

NOTE: R is built to work with vectors. Many operations are vectorized, i.e. by default they will happen component-wise when given a vector as input. Novices often don’t internalize or exploit this and they write lots of unnecessary for loops.

``` r
n <- 8
set.seed(1)
(w <- round(rnorm(n), 2)) # numeric floating point
```

    ## [1] -0.63  0.18 -0.84  1.60  0.33 -0.82  0.49  0.74

``` r
#> [1] -0.63  0.18 -0.84  1.60  0.33 -0.82  0.49  0.74
(x <- 1:n) # numeric integer
```

    ## [1] 1 2 3 4 5 6 7 8

``` r
#> [1] 1 2 3 4 5 6 7 8
## another way to accomplish by hand is x <- c(1, 2, 3, 4, 5, 6, 7, 8)
(y <- LETTERS[1:n]) # character
```

    ## [1] "A" "B" "C" "D" "E" "F" "G" "H"

``` r
#> [1] "A" "B" "C" "D" "E" "F" "G" "H"
(z <- runif(n) > 0.3) # logical
```

    ## [1]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE FALSE

``` r
#> [1]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE FALSE

str(w)
```

    ##  num [1:8] -0.63 0.18 -0.84 1.6 0.33 -0.82 0.49 0.74

``` r
#>  num [1:8] -0.63 0.18 -0.84 1.6 0.33 -0.82 0.49 0.74
length(x)
```

    ## [1] 8

``` r
#> [1] 8
is.logical(y)
```

    ## [1] FALSE

``` r
#> [1] FALSE
as.numeric(z)
```

    ## [1] 1 1 1 1 1 0 1 0

``` r
#> [1] 1 1 1 1 1 0 1 0
```

#### 17.2 Indexing a vector

We’ve said, and even seen, that square brackets are used to index a vector. There is great flexibility in what one can put inside the square brackets and it’s worth understanding the many options. They are all useful, just in different contexts.

Most common, useful ways to index a vector:

-   logical vector: keep elements associated with TRUE’s, ditch the FALSE’s
-   vector of positive integers: specifying the keepers
-   vector of negative integers: specifying the losers
-   character vector: naming the keepers

``` r
w
```

    ## [1] -0.63  0.18 -0.84  1.60  0.33 -0.82  0.49  0.74

``` r
#> [1] -0.63  0.18 -0.84  1.60  0.33 -0.82  0.49  0.74
names(w) <- letters[seq_along(w)]
w
```

    ##     a     b     c     d     e     f     g     h 
    ## -0.63  0.18 -0.84  1.60  0.33 -0.82  0.49  0.74

``` r
#>     a     b     c     d     e     f     g     h 
#> -0.63  0.18 -0.84  1.60  0.33 -0.82  0.49  0.74
w < 0
```

    ##     a     b     c     d     e     f     g     h 
    ##  TRUE FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE

``` r
#>     a     b     c     d     e     f     g     h 
#>  TRUE FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE
which(w < 0)
```

    ## a c f 
    ## 1 3 6

``` r
#> a c f 
#> 1 3 6
w[w < 0]
```

    ##     a     c     f 
    ## -0.63 -0.84 -0.82

``` r
#>     a     c     f 
#> -0.63 -0.84 -0.82
seq(from = 1, to = length(w), by = 2)
```

    ## [1] 1 3 5 7

``` r
#> [1] 1 3 5 7
w[seq(from = 1, to = length(w), by = 2)]
```

    ##     a     c     e     g 
    ## -0.63 -0.84  0.33  0.49

``` r
#>     a     c     e     g 
#> -0.63 -0.84  0.33  0.49
w[-c(2, 5)]
```

    ##     a     c     d     f     g     h 
    ## -0.63 -0.84  1.60 -0.82  0.49  0.74

``` r
#>     a     c     d     f     g     h 
#> -0.63 -0.84  1.60 -0.82  0.49  0.74
w[c('c', 'a', 'f')]
```

    ##     c     a     f 
    ## -0.84 -0.63 -0.82

``` r
#>     c     a     f 
#> -0.84 -0.63 -0.82
```
