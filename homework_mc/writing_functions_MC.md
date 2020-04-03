Functions in R
================
Michelle Coombe
2020-04-03

### Load libraries and data

``` r
library(tidyverse)
```

    ## ── Attaching packages ──────────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.3.0     ✓ purrr   0.3.3
    ## ✓ tibble  2.1.3     ✓ dplyr   0.8.5
    ## ✓ tidyr   1.0.2     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.5.0

    ## ── Conflicts ─────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(gapminder)
```

Notes in this document are primarily from the original
[stat545](https://stat545.com/functions-part1.html), but also from the R
for Data Science [ebook](https://r4ds.had.co.nz/functions.html), and the
newer
[ubcstat545](https://stat545guidebook.netlify.com/functional-programming-in-r-part-i.html).

## Random notes to help understand how R works with functions

### Indexing and vectorized operations

Using square brackets to isolate elements of a vector = indexing. Index
value begin at ‘1’ in R, which seems obvious, but apparently most other
languages start at ‘0’.

Most operations in R are *vectorized*, meaning that by default they will
happen component-wise when given a vector as an input. This is very
useful to understand as it avoids a lot of unnecessary `for` loops\!

``` r
x <-  1:4

#Vectorized version of squaring 'x'
(y <- x^2)
```

    ## [1]  1  4  9 16

``` r
#For loop version of squaring 'x'
  #Need something for the results of the for loop to be placed into
z <- vector(mode = mode(x), length = length(x))
z
```

    ## [1] 0 0 0 0

``` r
for (i in seq_along(x)) {
  z[i] <- x[i]^2
}

#These end up with the same result
identical(y, z)
```

    ## [1] TRUE

However, be unaware of vectorizing can also lead to traps, as (a) it can
lead to unexpected results if you don’t intend for this behaviour, and
(b) it means that R will recycle vectors if they are not of the
necessary length. It is good practice to check your R objects to make
sure they are what you expect in terms of outputs, flavors, and
length/dimensions\!

``` r
(y <-  1:3)
```

    ## [1] 1 2 3

``` r
(z <- 3:7)
```

    ## [1] 3 4 5 6 7

``` r
y + z #R will warn you of uneven lengths here
```

    ## Warning in y + z: longer object length is not a multiple of shorter object
    ## length

    ## [1] 4 6 8 7 9

``` r
(y <- 1:10)
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10

``` r
(z <- 3:7)
```

    ## [1] 3 4 5 6 7

``` r
y + z #But not here...I think because length(y) is a multiple of length(z)...but this is bad news!
```

    ##  [1]  4  6  8 10 12  9 11 13 15 17

### Lists:

Lists are like a vector but do not require that the elements are of the
same flavor Data frames are a special case of a list where each element
is an atomic vector, and all elements have the same length. Many
functions will return lists to you and you will want to get at the
list’s innards. The components of a list also have names, and you can
create or change names using the `names` function.

Extracting elements from a list. See R for Data Science’s
[condiments](https://r4ds.had.co.nz/vectors.html#lists-of-condiments)
section for great visual overview (also section 20.5.2 above the pepper
shaker bit is quite useful too). Note that you have to use the double
bracket approach, as opposed to the dollar sign, when the indexing
object itself is an R object (eg “iWantThis” in the example below.
Additionally, if you want more than one element, you must use
vector-style indexing with **single** square brackets: this will always
return another list (even if you request only 1 element). If you subset
using double square brackets (for ONE element) you will be the flavor of
that element.

Summary of how to extract using square brackets:

  - x\[1\] returns the first element (eg data frame) in a list, still
    surrounded by a list wrapper

  - x\[\[1\]\] returns only the first element (eg the data frame
    itself), without a list wrapper

  - x\[\[1\]\]\[1\] returns the first element of the data frame within
    our list, surrounded by a list wrapper

  - x\[\[1\]\]\[\[1\]\] returns the first element of the data frame
    within our list, without the list or data frame wrappers

<!-- end list -->

``` r
(a <- list(veg = c("cabbage", "eggplant"),
           tNum = c(pi, exp(1), sqrt(2)),
           myAim = TRUE,
           joeNum = 2:6))
```

    ## $veg
    ## [1] "cabbage"  "eggplant"
    ## 
    ## $tNum
    ## [1] 3.141593 2.718282 1.414214
    ## 
    ## $myAim
    ## [1] TRUE
    ## 
    ## $joeNum
    ## [1] 2 3 4 5 6

``` r
# Explore this list
str(a)
```

    ## List of 4
    ##  $ veg   : chr [1:2] "cabbage" "eggplant"
    ##  $ tNum  : num [1:3] 3.14 2.72 1.41
    ##  $ myAim : logi TRUE
    ##  $ joeNum: int [1:5] 2 3 4 5 6

``` r
length(a)
```

    ## [1] 4

``` r
class(a)
```

    ## [1] "list"

``` r
mode(a) #Note this tells you the STORAGE mode, not the statistical mode!!!!
```

    ## [1] "list"

``` r
#Ways to get to a single element
a[[2]]    #index with a positive integer
```

    ## [1] 3.141593 2.718282 1.414214

``` r
a$myAim   #use dollar sign and element name
```

    ## [1] TRUE

``` r
str(a$myAim) #we get myAim itself, a length of 1 logical vector
```

    ##  logi TRUE

``` r
a[["tNum"]]  #index with a length 1 character vector
```

    ## [1] 3.141593 2.718282 1.414214

``` r
str(a[["tNum"]])  #we get tNum itself, a length 3 numeric vector
```

    ##  num [1:3] 3.14 2.72 1.41

``` r
iWantThis <- "joeNum"  #indexing with a length 1 character object
a[[iWantThis]]  #we get joeNum itself, a length 5 integer vector
```

    ## [1] 2 3 4 5 6

``` r
# a[[c("joeNum", "veg")]]  #This does NOT work!!! Can't get >1 elements!!! Can't knit with the operation either...

#Ways to get multiple elements
names(a)
```

    ## [1] "veg"    "tNum"   "myAim"  "joeNum"

``` r
a[c("tNum", "veg")]   #indexing by length 2 character vector
```

    ## $tNum
    ## [1] 3.141593 2.718282 1.414214
    ## 
    ## $veg
    ## [1] "cabbage"  "eggplant"

``` r
str(a[c("tNum", "veg")])  #Returns a list of length 2
```

    ## List of 2
    ##  $ tNum: num [1:3] 3.14 2.72 1.41
    ##  $ veg : chr [1:2] "cabbage" "eggplant"

``` r
str(a["veg"])   #returns a list of length 1
```

    ## List of 1
    ##  $ veg: chr [1:2] "cabbage" "eggplant"

``` r
length(a["veg"])
```

    ## [1] 1

``` r
length(a["veg"][[1]])  #contrast with the length of the veg vector itself
```

    ## [1] 2

### Matrices and data flavors:

A matrix is an alternative to data frames for storing rectangular data.
Matrices are generalizations of atomic vectors, so all elements must be
of the same class. Indexing is similar to that of a vector or a list,
except that you can use `[i, j]`, where `i` = row and `j` = column. You
can fill a matrix with a vector, by giving row and column numbers (and
names) at creation. If the input vector is not long enough, R will
recycle it.

``` r
matrix(1:15, nrow = 5)
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    6   11
    ## [2,]    2    7   12
    ## [3,]    3    8   13
    ## [4,]    4    9   14
    ## [5,]    5   10   15

``` r
matrix("yo!", nrow = 3, ncol = 6)
```

    ##      [,1]  [,2]  [,3]  [,4]  [,5]  [,6] 
    ## [1,] "yo!" "yo!" "yo!" "yo!" "yo!" "yo!"
    ## [2,] "yo!" "yo!" "yo!" "yo!" "yo!" "yo!"
    ## [3,] "yo!" "yo!" "yo!" "yo!" "yo!" "yo!"

``` r
matrix(c("yo!", "foo?"), nrow = 3, ncol = 6)
```

    ##      [,1]   [,2]   [,3]   [,4]   [,5]   [,6]  
    ## [1,] "yo!"  "foo?" "yo!"  "foo?" "yo!"  "foo?"
    ## [2,] "foo?" "yo!"  "foo?" "yo!"  "foo?" "yo!" 
    ## [3,] "yo!"  "foo?" "yo!"  "foo?" "yo!"  "foo?"

``` r
matrix(1:15, nrow = 5, byrow = TRUE)
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6
    ## [3,]    7    8    9
    ## [4,]   10   11   12
    ## [5,]   13   14   15

``` r
matrix(1:15, nrow = 5,
       dimnames = list(paste0("row", 1:5),
                       paste0("col", 1:3)))
```

    ##      col1 col2 col3
    ## row1    1    6   11
    ## row2    2    7   12
    ## row3    3    8   13
    ## row4    4    9   14
    ## row5    5   10   15

Note that if your elements are not of the same flavor, it may either
convert everything to the lowest common flavor (usually character), or
you will either get an error, or R can silently fail. This is why it is
really important to understand the data flavors in your objects\!\!\!

``` r
multiDat <- data.frame(vec1 = 5:1,
                       vec2 = paste0("hi", 1:5))
str(multiDat)
```

    ## 'data.frame':    5 obs. of  2 variables:
    ##  $ vec1: int  5 4 3 2 1
    ##  $ vec2: Factor w/ 5 levels "hi1","hi2","hi3",..: 1 2 3 4 5

``` r
(multiMat <- as.matrix(multiDat))
```

    ##      vec1 vec2 
    ## [1,] "5"  "hi1"
    ## [2,] "4"  "hi2"
    ## [3,] "3"  "hi3"
    ## [4,] "2"  "hi4"
    ## [5,] "1"  "hi5"

``` r
str(multiMat)  #Oh bad news - first element is now just 'NULL' instead of integers...
```

    ##  chr [1:5, 1:2] "5" "4" "3" "2" "1" "hi1" "hi2" "hi3" "hi4" "hi5"
    ##  - attr(*, "dimnames")=List of 2
    ##   ..$ : NULL
    ##   ..$ : chr [1:2] "vec1" "vec2"

Table of atomic R object flavors (very handy\!\!\!) *Note the following
will look great when rendered with pandoc but terrible in html, but is a
good example of how to make a text table with centered values*
|:———:|:————-:|:———:|:———:| | “flavor” | type reported |
mode() | class() | | | by typeof() | | | | character | character |
character | character | | logical | logical | logical | logical | |
numeric | integer | numeric | integer | | | or double | | or double | |
factor | integer | numeric | factor |

``` r
# Legible in any format
#  +-----------+---------------+-----------+-----------+
#  | "flavor"  | type reported | mode()    | class()   |
#  |           | by typeof()   |           |           |
#  +===========+===============+===========+===========+
#  | character | character     | character | character |
#  +-----------+---------------+-----------+-----------+
#  | logical   | logical       | logical   | logical   |
#  +-----------+---------------+-----------+-----------+
#  | numeric   | integer       | numeric   | integer   |
#  |           | or double     |           | or double |
#  +-----------+---------------+-----------+-----------+
#  | factor    | integer       | numeric   | factor    |
#  +-----------+---------------+-----------+-----------+
```

## Outline for writing your own function

When to write a function? The general rule of thumb seems to be if
you’ve copied and pasted code 3 or more times. Yes, copy and paste is
fast, but it is also WAY more prone to unnotice errors and will cause
headaches down the line\!\!\!

The process for writing a function follows the idea of building a
minimum viable product: a limited-but-functioning thing is still very
useful and easier to build into a more complex thing than just building
the more complex thing straight from scratch.

General steps are as follows:

1.  Develop some working, interactive code.

<!-- end list -->

1)  This means that you start with a **simple** problem (or multiple
    simple problems). It is really important that you know what to
    expect for your output (e.g. data flavor, length, possible
    values)\!\!\!

2)  Then develop a working snippet of code that solves this problem(s).

3)  Test the snippet of code with test data, including some unexpected
    values (e.g. NAs, values outside of expected range, different
    flavors of data, different data types (vector vs data frame vs
    list)). This will give you an idea of when/where it might fail and
    if it fails, what you expect it to do. More on testing later.

<!-- end list -->

2.  Rewrite your snippet of code to use temporary variables. These
    temporary variables should be used where elements of code are
    repeated and/or when inputs are needed. Make sure to use **clear**
    names, not just a letter (in most cases) as it makes
    trouble-shooting down the line more difficult and readability for
    other users (i.e. future you\!) much more difficult.

3.  Re-write your code for clarity.

4.  NOW turn your code snippet into a function by adding the
    `function(arguments) {}` part. Recall that the value of the last
    evaluated expression will be returned; however, if you call `return`
    within the function, that expression will be evaluated, the value
    returned, and the function will stop here (so **careful** if/where
    you use return calls\!\!\!)

5.  Test that new function\!

<!-- end list -->

1)  Use on some test data that mimics your intended data and where you
    (roughly) know what it should return.

2)  Use on real data but *different* real data (e.g. other similar
    flavor variables in your dataset, an entirely different dataset with
    similar flavors of variables or data types like data frame or
    lists).

3)  Use on weird stuff. Here you are trying to break your function. Use
    NAs, values outside of range, different flavors, different data
    types.

<!-- end list -->

6.  Based on results of step 5, ensure your function fails noisily and
    as soon as possible and insert informative error messages. See
    section below. Also note that you can skip this step if you are not
    intending to re-use your function; no sense in just making extra
    work for yourself.

## Making functions fail and writing informative error messages

Insert notes on stopifnot and informative error messages

Insert notes how to do validity checks on your functions to make sure
they are doing what you think they are (see part 1 and part 2 examples)
And how to make them fail in expected ways

Notes on generalizing functions

``` r
mmm <- function(x) {
  stopifnot(is.numeric(x))
  max(x) - min(x)
}
```

Reminder that function argument names can be anything but convention is
to use meaningful names and if you are reusing functions or arugments in
other functions, use the same names just to make it easier to remember

Notes on how to return output from a function

Notes on default values

## Write your own Functions, part 3
