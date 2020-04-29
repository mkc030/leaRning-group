Functions in R
================
Michelle Coombe
2020-04-29

### Load libraries and data

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.3.0     ✓ purrr   0.3.3
    ## ✓ tibble  2.1.3     ✓ dplyr   0.8.5
    ## ✓ tidyr   1.0.2     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.5.0

    ## ── Conflicts ───────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(gapminder)
library(lubridate)
```

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:base':
    ## 
    ##     date

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

#### Logical evaluations, if statments, and vectorization

The `|`, `&` and `==` evaluators are vectorized and apply to multiple
values and should never be used in programming control flow and certain
conditional statements (e.g. `if()`). Instead, you can use `||` and `&&`
where the double operators returns `TRUE` for the first instance of
`TRUE` it sees, and returns `FALSE` for the first instance of `FALSE` it
sees. The double operators are “short circuits”. Thus, while the single
sign version compares at each element (i.e. is vectorized), while the
double sign evaluates from left to right, examining only the first
element of each vector, and evaluation stops once a result is
determined. In terms of output, the short form will result in a logical
vector, while the double operators will return only one value. `if()`
statements need a result of length 1 and will not work with a logical
vector, hence why you should never use the single operators. However, a
logical vector would be appropriate to an `ifelse()`
statement.

``` r
c(T, T, F) & c(T, F, F)
```

    ## [1]  TRUE FALSE FALSE

``` r
c(T, T, F) && c(T, F, F)
```

    ## [1] TRUE

``` r
c(T, T, F) | c(T, F, F)
```

    ## [1]  TRUE  TRUE FALSE

``` r
c(T, T, F) || c(T, F, F)
```

    ## [1] TRUE

``` r
#example of short-circuiting (i.e. only evaluating as many terms as they need to get a result)
  #For some reason, these won't let me knit if they are unhashed...sigh...
# a     #This throws an error
# TRUE || a     #TRUE
# FALSE || a    #Error: object 'a' not found
# TRUE | a      #Error: object 'a' not found
# FALSE & a     #Error: object 'a' not found
```

Alternatively, you can use `any()` or `all()` to collapse a vector
(logical for `|` or `&`, or any type for `==` equivalencies) down to a
single value. Another alternative for determining equivalency is to use
`identical()`, although it is very strict and will not convert between
different types (i.e. `identical(1L, 1)` returns `F`) and measures down
to smallest possible value for integers and doubles, so use with
caution\! For comparing integers and doubles, `dyplyr::near()` may be a
better option.

Don’t forget that `TRUE` coerces to 1 and `FALSE` coerces to 0.

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

Data frames are a special case of a list, where all the columns need to
be the same length. However each column in a normal data frame is a
vector, while columns in a tibble can be lists. This is important to
remember when wanting to iterate over different columns, as it means you
can use purrr and other functions that take vectors and/or lists as
inputs\! Look at the nested data frame section for more on how this can
be useful.

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

## Control structure and conditional statements: If, Ifelse, else, Switch and Cut functions

Conditional statements are useful to controling how and when certain
expressions are evaluted such as *if* `if(condition) { expression }`. If
the condition of the *if* statment evaluates to FALSE, then the
following expression is NOT executed and you will not get your result.
If you want something done if the *if* condition evaluates to FALSE you
can also add *else* `if(condition) { expr1 } else { expr2 }`, and/or
*else if* `if(condition) { expr1 } else if(condition2) { expr2 } else {
expr3 }` . Note that the `else` keyword **must** be on the same line as
the closing bracket of the `if` statement\!

A very important note with *if*, *else if*, and *else* statements is
that R will execute through the code until it hits the **first
condition** which evaluates to TRUE, then stops and does NOT execute the
rest of the code. This is very important to keep in mind if you’ve made
statements that are not mutuatally exclusive\!\!\!

If you are getting confused about how your conditional statement is
being evaluated, substitute your desired result with text and a print
statement, so that you can see where in the conditional statement your
results are being evaluated from (and if it is working as expected or
not\!\!\!)

``` r
number <- 56

if(number < 10){
  if(number < 5){
    result <- "extra small"
  } else {
    result <- "small"
  }
  } else if(number < 100) {
    result <- "medium"
  } else {
    result <- "large"
  }
  print(result)
```

    ## [1] "medium"

Alternatively, if you only have 2 conditions, you can just use an
`ifelse` statement rather than `if` then `else` statements. The format
is: ifelse(condition.to.test, yes = return.value.if.T, no =
return.value.if.F). Note that this function strips attributes
(e.g. class) from the input, so use caution or (better yet) do NOT use
with dates or factors.

``` r
x <- c(6:-4)
ifelse(x >= 0, sqrt(x), NA) #note you will get a warning that NaNs are produced
```

    ## Warning in sqrt(x): NaNs produced

    ##  [1] 2.449490 2.236068 2.000000 1.732051 1.414214 1.000000 0.000000       NA
    ##  [9]       NA       NA       NA

``` r
sqrt(ifelse(x >= 0, x, NA)) #notice that you will NOT get a warning that NaNs are produced here
```

    ##  [1] 2.449490 2.236068 2.000000 1.732051 1.414214 1.000000 0.000000       NA
    ##  [9]       NA       NA       NA

However, if you are writing a long series of chained *if* statements,
you should instead consider using alternative functions.

  - `switch` evaluates selected code based on position or name. Format
    is: `switch(object, case = action)`

<!-- end list -->

``` r
basic_maths <- function(x, y, op) {
                  switch (op,
                    plus = x + y,
                    minus = x - y,
                    times = x * y,
                    divide = x / y,
                    stop("Unknown op!")
                  )
                }

basic_maths(x = 10, y = 5, op = "times")
```

    ## [1] 50

  - `cut` is useful to turn continuous variables into discrete
    categories. The argument ‘breaks’ can be supplied as a single number
    (which divides the data into n = break pieces of equal length) or a
    numeric vector of two or more unique cut points. The ‘right’
    argument (default = T) specifies if intervals should be closed on
    the right and open on the left, or vice versa. There is also a
    ‘labels’ argument. Finally, note that there is also a `cut.Date`
    function for class ‘Date’ or ‘POSIXt’ objects. Note that ‘cut.Date’
    does NOT work on date ‘Interval’ class.

<!-- end list -->

``` r
Z <- 1:100
table(cut(Z, breaks = 5, labels = F))
```

    ## 
    ##  1  2  3  4  5 
    ## 20 20 20 20 20

``` r
table(cut(Z, breaks = 5))
```

    ## 
    ## (0.901,20.8]  (20.8,40.6]  (40.6,60.4]  (60.4,80.2]   (80.2,100] 
    ##           20           20           20           20           20

``` r
table(cut(Z, breaks = 5, right = F))
```

    ## 
    ## [0.901,20.8)  [20.8,40.6)  [40.6,60.4)  [60.4,80.2)   [80.2,100) 
    ##           20           20           20           20           20

``` r
mydates <- seq(from = ymd("2016-09-01"), to = ymd("2018-08-30"), by = "week")
table(cut.Date(mydates, breaks = "month")) 
```

    ## 
    ## 2016-09-01 2016-10-01 2016-11-01 2016-12-01 2017-01-01 2017-02-01 2017-03-01 
    ##          5          4          4          5          4          4          5 
    ## 2017-04-01 2017-05-01 2017-06-01 2017-07-01 2017-08-01 2017-09-01 2017-10-01 
    ##          4          4          5          4          5          4          4 
    ## 2017-11-01 2017-12-01 2018-01-01 2018-02-01 2018-03-01 2018-04-01 2018-05-01 
    ##          5          4          4          4          5          4          5 
    ## 2018-06-01 2018-07-01 2018-08-01 
    ##          4          4          5

``` r
table(cut.Date(mydates, breaks = "month", labels = F)) 
```

    ## 
    ##  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 
    ##  5  4  4  5  4  4  5  4  4  5  4  5  4  4  5  4  4  4  5  4  5  4  4  5

## Outline for writing your own function

When to write a function? The general rule of thumb seems to be if
you’ve copied and pasted code 3 or more times. Yes, copy and paste is
fast, but it is also WAY more prone to unnotice errors and will cause
headaches down the line\!\!\!

The process for writing a function follows the idea of building a
minimum viable product: a limited-but-functioning thing is still very
useful and easier to build into a more complex thing than just building
the more complex thing straight from scratch.

DRY principle: “do not repeat yourself”. The more repetition is in your
code, the more likely you will forget to update everything when things
change. Be kind to collaborators and future you.

General function writing steps are as follows:

1.  Develop some working, interactive code.

<!-- end list -->

1)  This means that you start with a **simple** problem (or multiple
    simple problems). It is really important that you know what to
    expect for your output (e.g. data flavor, length, possible
    values)\!\!\!

<!-- end list -->

``` r
df <- tibble::tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# Goal = to rescale each column!
```

2)  Then develop a working snippet of code that solves this problem(s).
    Having issues trying to make a working snippet of code using purrr
    functions (or even with loops)? See example under purrr section
    which shows a trick Hadley Wickham uses to help break this process
    down and figure out where things are going astray.

<!-- end list -->

``` r
df$a <- (df$a - min(df$a, na.rm = TRUE)) / 
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$b <- (df$b - min(df$b, na.rm = TRUE)) / 
  (max(df$b, na.rm = TRUE) - min(df$a, na.rm = TRUE))  #Notice the copy and paste mistake here!!!
df$c <- (df$c - min(df$c, na.rm = TRUE)) / 
  (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
df$d <- (df$d - min(df$d, na.rm = TRUE)) / 
  (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))
```

3)  Test the snippet of code with test data, including some unexpected
    values (e.g. NAs, values outside of expected range, different
    flavors of data, different data types (vector vs data frame vs
    list)). This will give you an idea of when/where it might fail and
    if it fails, what you expect it to do. More on testing
later.

<!-- end list -->

``` r
#No ex here as actually 'R for data science' does this testing step at the end of writing a function...
#But how much/when you test during and after making a function probably depends on its complexity
```

2.  Rewrite your snippet of code to use temporary variables. These
    temporary variables should be used where elements of code are
    repeated and/or when inputs are needed. Make sure to use **clear**
    names, not just a letter (in most cases) as it makes
    trouble-shooting down the line more difficult and readability for
    other users (i.e. future you\!) much more difficult.

<!-- end list -->

``` r
# Start by focusing on only one column in the dataset
df$a <- (df$a - min(df$a, na.rm = TRUE)) / 
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
```

  - Use temporary variables for the inputs; you can start with a very
    short, generic name to see where the inputs are (i.e. ‘x’) and then
    re-write the variable names for clarity

<!-- end list -->

``` r
# Figure out the inputs and replace with temporary variables
x <- df$a
(x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
```

    ##  [1] 0.63811863 0.44553979 0.25122836 0.08919522 0.66277579 1.00000000
    ##  [7] 0.22400567 0.00000000 0.42858372 0.55599662

``` r
#Now you can see you are actually calculating the range three times!!! This leads to step 3
```

  - Final variable names for inputs (aka argmuments) should be nouns

<!-- end list -->

3.  Re-write your code for clarity. For instance, pull out the
    intermediate calculations into named variable to simplify the code.
    This makes it much more clear what the code is
doing\!

<!-- end list -->

``` r
# Pull out intermediate calculations into a named variable (e.g. we are calculating the range)
rng <- range(x, na.rm = TRUE)
(x - rng[1]) / (rng[2] - rng[1])
```

    ##  [1] 0.63811863 0.44553979 0.25122836 0.08919522 0.66277579 1.00000000
    ##  [7] 0.22400567 0.00000000 0.42858372 0.55599662

4.  NOW turn your code snippet into a function by adding the
    `function(arguments) {}` part. Recall that the value of the last
    evaluated expression will be returned; however, if you call `return`
    within the function, that expression will be evaluated, the value
    returned, and the function will stop here (so **careful** if/where
    you use return calls\!\!\!)

<!-- end list -->

1)  Pick a descriptive name for your function. Function names should
    generally be verbs (although sometimes a noun may be more
    appropriate if your verb is very broad (e.g. get, compute,
    determine, calculate) For instance, ‘get\_mean()’ probably should
    just be ‘mean()’. Seperate words with an underscore (note that I’ve
    also seen R style guides say that words in objects and function
    should be seperated with a period…so just pick a convention and be
    consistent.) Reminder that function argument names can be anything
    but convention is to use meaningful names and if you are reusing
    functions or arugments in other functions, use the same names just
    to make it easier to remember (e.g. input\_animals, input\_inverts,
    input\_plants vs. plants\_input, inverts\_input, plants\_input).

2)  List the inputs (aka arguments) inside the function, for instance
    `function(x, y, z)`.

3)  Place the working snippet of code inside the body of the functions
    (aka in the `{}` part)

<!-- end list -->

``` r
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(c(0, 5, 10))
```

    ## [1] 0.0 0.5 1.0

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

4)  Use automated tests\! See the `testthat` package and the R packages
    book section on [testing](http://r-pkgs.had.co.nz/tests.html). Looks
    too complicated to throw in the mix right now, but likely very
    useful to follow up on in the future.

<!-- end list -->

``` r
# Test on some different possible data
rescale01(c(-10, 0, 10))
```

    ## [1] 0.0 0.5 1.0

``` r
rescale01(c(1, 2, 3, NA, 5))
```

    ## [1] 0.00 0.25 0.50   NA 1.00

``` r
x <- c(1:10, Inf)
rescale01(x) #Huh, this is an issue...
```

    ##  [1]   0   0   0   0   0   0   0   0   0   0 NaN

``` r
# But easy to fix now that we have code in a working function!
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(x)
```

    ##  [1] 0.0000000 0.1111111 0.2222222 0.3333333 0.4444444 0.5555556 0.6666667
    ##  [8] 0.7777778 0.8888889 1.0000000       Inf

``` r
# Seems ok, so now can use on your original dataset
df$a <- rescale01(df$a)
df$b <- rescale01(df$b)
df$c <- rescale01(df$c)
df$d <- rescale01(df$d)
```

6.  Based on results of step 5, ensure your function fails noisily and
    as soon as possible and insert informative error messages. See
    section below. Also note that you can skip this step if you are not
    intending to re-use your function; no sense in just making extra
    work for yourself.

## Making functions fail and writing informative error messages

It is important to check the validity of your arguments so you are aware
if your function is not behaving as expected. It is also very helpful if
you write in useful error messages, rather than generic ones, as
otherwise it can get tricky (especially for future you that has
forgotten all about this function) to figure out why something suddenly
isn’t working any more.

  - `stopifnot` is useful to check the validity of arguments. For
    instance, is your input numeric as expected? Are there NAs that need
    to be removed? Recall that `stopifnot` is evaluating if something is
    TRUE rather than you asserting what might be wrong and stops the
    function if the evaluation = F. It does not provide a very helpful
    error message though. Important to remember that *you are putting
    the condition you want to be TRUE inside the function*.

<!-- end list -->

``` r
mmm <- function(x) {
  stopifnot(is.numeric(x))
  max(x) - min(x)
}
mmm(gapminder$lifeExp)
```

    ## [1] 59.004

``` r
#mmm("eggplants are purple") #Throws an error; won't let me knit with it in

# More complex example
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(w))
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}

# wt_mean(1:6, 6:1, na.rm = "foo") #Throws an error; won't let me know with it in
```

  - `if` and then `stop` is another option for evaluting inputs. This
    option lets you write a more informative error message, but
    important to remember *you are putting the condition that you do NOT
    want to happen inside your ‘if’ statement*. In other words, your
    argument is specifying under what condition you want the function to
    STOP. It is also useful to supply the `call. = F` argument, meaning
    that the call to the function should not be included in the error
    message.

<!-- end list -->

``` r
mmm2 <- function(x) {
  if(!is.numeric(x)) {
    stop('I am so sorry, but this function only works for numeric input!\n',
         'You have provided an object of class: ', class(x)[1])
  }
  max(x) - min(x)
}
# mmm2(gapminder)  #Throws an error; won't let me knit with this in

mmm3 <- function(x) {
  if(!is.numeric(x)) {
    stop('I am so sorry, but this function only works for numeric input!\n',
         'You have provided an object of class: ', class(x)[1],
         call. = FALSE) #Add this to suppress the call the function in your error message. Makes things less confusing to read
  }
  max(x) - min(x)
}
# mmm3(gapminder)   #Throws an error; won't let me knit with this in
```

*Notes on how to return output from a function*

*Notes on default values*

## For and While Loops

*STILL NEED TO PUT NOTES IN HERE, see intermediate R chapter 2
especially for ‘break’ and ‘next’ statements*

  - length of loops: you can use either `i in 1:length(x)` or `i in
    seq_along(x)`. The latter is probably safer, as `length` can
    sometimes lead to unexpected results.

## Functional programing with Purrr

This is primarily from Rebecca Barter’s
[blog](http://www.rebeccabarter.com/blog/2019-08-19_purrr/) but it seems
like Jenny Bryan also has a useful
[tutorial](https://jennybc.github.io/purrr-tutorial/index.html) to go
through.

First thing to remember is that purrr works on **lists** or **columns in
tibbles** (which can be lists vs. vectors as they are in regular data
frames). Tibbles can become **nested** where it is split into seperate
data frames based on a grouping variable, and these seperate data frames
are stored as enteries of a list (that is then stored in the ‘data’
column of the data frame). This is where purrr and tibbles shine\!

Purrr is about iterations: it’s like doing a for loop, without having to
write the loop part. Purrr applies a function across entries of a list
or vector and returns an object of the type that is specified. First
argument (`.x`) is always the data and the second argument (`.f`) is
always the function you want applied. The data can be a vector (of any
type), a list (where iteration is done over each element in the list),
or a dataframe (which is a special type of list, and iteration is done
over the columns of the data frame).

Purrr’s basic map functions include:

  - `map(.x, .f)` returns a list

  - `map_df(.x, .f, .id)` returns a data frame. Note that you need to
    provide consistent column names for each iteration, or it will fail.
    The `.id` argument will either create a variable named using the
    character string specified, or the index (if .x is unnamed),. If
    NULL (default) no variable is created.

  - `map_dbl(.x, .f)` returns a numeric (double) vector

  - `map_chr(.x, .f)` returns a character vector

  - `map_lgl(.x, .f)` returns a logical vector

  - `map_dfc()` and `map_dfr()` are special cases that return data
    frames created through either column-binding or row-binding

  - `map2(.x, .y, .f)` and friends (eg `map2_dbl()`) iterates over 2
    argmuments simultaneously. This is similar to how `base::pmax`
    works. Note that input vectors (.x and .y) must be of the same
    length and otherwise will be recycled. See notes on iteration below.

  - `pmap(.l, .f)` and friends (eg `pmap_lgl()`) iterates over multiple
    arguments simultaneously. Note that `.l` is a list of vectors (which
    can be a data frame, by definition\!). The length of `.l` determines
    the number of arguments that `.f` will be called with.

  - `walk(.x, .f)` is used when you want to use a function for its side
    effect (e.g. plots, printing, saving files) and it returns the input
    .x. It sounds wierd, but actually the fact that `walk` returns the
    object you passed to them is very useful - it means you can use them
    in pipelines\!

  - `invoke_map(.f, .x = list(NULL))` and family is used to call a list
    of functions with a list of parameters. It is retired (but still
    maintained) in favour of the newer `exec()`

One last introductory note is on **anonymous functions**, which are
functions created as arguments of other functions (and are usually
defined on the same line as you use them in). You can use a tilde-dot
shorthand for these functions, making them easier to read\! The `~`
replaces the `function(x)` part and the argument can be referred to as
`.x` or just `.`. You CANNOT name the arguments anything you want using
this shorthand\!

Basic example of how to use purrr and a function, anonymous functions,
and adding results back to a data frame.

``` r
addTen <- function(.x) {
  return(.x + 10)
}

# Map returns a list
map(.x = c(1, 4, 7),
    .f = addTen) 
```

    ## [[1]]
    ## [1] 11
    ## 
    ## [[2]]
    ## [1] 14
    ## 
    ## [[3]]
    ## [1] 17

``` r
#How to do with using an anonymous function and returning a numeric vector
#Method 1 - define within the same line
map_dbl(c(1, 4, 7), function(.x){return(.x + 10)})
```

    ## [1] 11 14 17

``` r
#Method 2 - define using tilda-dot shorthand
map_dbl(c(1, 4, 7), ~{.x +10})
```

    ## [1] 11 14 17

``` r
# map_df returns a data frame BUT you need consistent column names for each iteration
#This fails
map(c(1, 4, 7),
    addTen)
```

    ## [[1]]
    ## [1] 11
    ## 
    ## [[2]]
    ## [1] 14
    ## 
    ## [[3]]
    ## [1] 17

``` r
#This works
map_df(data.frame(a = 1, b = 4, c = 7),
       addTen)
```

    ## # A tibble: 1 x 3
    ##       a     b     c
    ##   <dbl> <dbl> <dbl>
    ## 1    11    14    17

``` r
# Adding your new number to your old data frame
map_df(c(1, 5, 7),
       function(.x){
         return(data.frame(old_number = .x,
                           new_number = addTen(.x)))
       })
```

    ##   old_number new_number
    ## 1          1         11
    ## 2          5         15
    ## 3          7         17

``` r
# How and when to use the .id for data frames to keep the variable names
#Don't specify .id means you lose the column names
gapminder %>% map_df(~(data.frame(unique_values = n_distinct(.x),
                                  column_class = class(.x))))
```

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector

    ##   unique_values column_class
    ## 1           142       factor
    ## 2             5       factor
    ## 3            12      integer
    ## 4          1626      numeric
    ## 5          1704      integer
    ## 6          1704      numeric

``` r
#Use .id to keep the column names in a new column called "variable_name"
gapminder %>% map_df(~(data.frame(unique_values = n_distinct(.x),
                                  column_class = class(.x))),
                     .id = "variable_name")
```

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector

    ##   variable_name unique_values column_class
    ## 1       country           142       factor
    ## 2     continent             5       factor
    ## 3          year            12      integer
    ## 4       lifeExp          1626      numeric
    ## 5           pop          1704      integer
    ## 6     gdpPercap          1704      numeric

``` r
#Example of using walk() for a side-effect (print in this case)
  #Note that this will PRINT each element (as 'print' is the function we used)
  #But it will return a list of the original object provided as .x
x <- list(1, "a", 3)

out <- walk(.x = x,
            .f = print)
```

    ## [1] 1
    ## [1] "a"
    ## [1] 3

``` r
str(out)
```

    ## List of 3
    ##  $ : num 1
    ##  $ : chr "a"
    ##  $ : num 3

``` r
#Alternatively, we can get a different output if we pipe to another purrr function
  #In this case, the length of each element in a numeric vector
  #But we STILL PRINT the value of each element in the list, as we piped to walk first
len_x <- x %>% walk(print) %>% map_dbl(length)
```

    ## [1] 1
    ## [1] "a"
    ## [1] 3

``` r
len_x
```

    ## [1] 1 1 1

``` r
  #Because walk() returns the original 'x' object—see str(out) above-it means we can pipe it along to other functions
```

**Iterating with purrr**: It is crucial to understand how iteration over
multiple objects works (i.e. with `map2`, `pmap`, `walk2`, `pwalk`). For
instance, if you wanted to summarize mean life expectancy in the
Gapminder dataset in continent-year pairs, you might assume that passing
`.x = gapminder$year` and `.y = gapminder$continent` to `map2` would
automatically perform `.f = mean` on *all* combinations of year and
continent. **This is not the case.** Instead, the *first iteration* of
`map2` will be the *first continent* in the continent vector and the
*first year* in the year vector; then, the *second iteration* will be
the *second continent* in the continent vector and the *second year* in
the year vector.

How to fix this problem? You need to make a vector where your first
value of your first input is repeated over all values of the second
input, and so forth. The point is to make two vectors that provide all
possible combination of
values.

``` r
### Method 1. Wrong way - define .x and .y only with unique values of each column
  #Notice that distinct can only work on tibbles, so need to pass gapminder using a pipe
# conts <- distinct(gapminder$continent)  #Throws an error; so can't knit with it unhashed
  #This does NOT work!!!

#So let's pull the element out of the list and then change into a character vector
conts <- gapminder %>% distinct(continent) %>% pull(continent) %>% as.character()
yrs <- gapminder %>% distinct(year) %>% pull(year) %>% as.character()

yrs <- yrs[1:length(conts)] #We'll subset this, or else map2 won't run with 2 vectors of different lengths
  #This should be your first clue that something is wrong!!!
  #But if your vectors happen to be the same lenght, it could cause issues if you aren't paying attention

conts     # "Asia"     "Europe"   "Africa"   "Americas" "Oceania"
```

    ## [1] "Asia"     "Europe"   "Africa"   "Americas" "Oceania"

``` r
yrs       #"1952" "1957" "1962" "1967" "1972"
```

    ## [1] "1952" "1957" "1962" "1967" "1972"

``` r
plot_list <- map2(.x = conts,
                  .y = yrs,
                  .f = ~{
                     gapminder %>% 
                       filter(continent == .x,
                              year == .y) %>% 
                       ggplot() +
                       geom_point(aes(gdpPercap, y = lifeExp)) +
                       ggtitle(glue::glue(.x, " ", .y))
                    })

length(plot_list) # 5 ?!?! But 5 continents x 5 years = 25...hmmmm....
```

    ## [1] 5

``` r
plot_list[[1]]
```

![](writing_functions_MC_files/figure-gfm/iterating%20in%20purrr-1.png)<!-- -->

``` r
plot_list[[2]] #This is NOT Asia in 1957!!!! Yup, iteration is not as maybe would inuitively expect...
```

![](writing_functions_MC_files/figure-gfm/iterating%20in%20purrr-2.png)<!-- -->

``` r
### Method 2: Correct way - define both vectors to have all possible combinations in separate "rows"
#Get all distinct combinations that occur
continent_year <- gapminder %>% distinct(continent, year)
head(continent_year, n = 20)
```

    ## # A tibble: 20 x 2
    ##    continent  year
    ##    <fct>     <int>
    ##  1 Asia       1952
    ##  2 Asia       1957
    ##  3 Asia       1962
    ##  4 Asia       1967
    ##  5 Asia       1972
    ##  6 Asia       1977
    ##  7 Asia       1982
    ##  8 Asia       1987
    ##  9 Asia       1992
    ## 10 Asia       1997
    ## 11 Asia       2002
    ## 12 Asia       2007
    ## 13 Europe     1952
    ## 14 Europe     1957
    ## 15 Europe     1962
    ## 16 Europe     1967
    ## 17 Europe     1972
    ## 18 Europe     1977
    ## 19 Europe     1982
    ## 20 Europe     1987

``` r
#NOW extract the continents and year pairs as separate vectors
conts <- continent_year %>% pull(continent) %>% as.character()
yrs <- continent_year %>% pull(year)

#Now plot
plot_list <- map2(.x = conts,
                  .y = yrs,
                  .f = ~{
                    gapminder %>% 
                      filter(continent == .x,
                             year == .y) %>% 
                      ggplot() +
                      geom_point(aes(x = gdpPercap, y = lifeExp)) +
                      ggtitle(glue::glue(.x, " ", .y))
                  })

length(plot_list) # 60;  5 continents x 12 years = 60 combinations...success!
```

    ## [1] 60

``` r
plot_list[[1]]
```

![](writing_functions_MC_files/figure-gfm/iterating%20in%20purrr-3.png)<!-- -->

``` r
plot_list[[2]] #Hooray!
```

![](writing_functions_MC_files/figure-gfm/iterating%20in%20purrr-4.png)<!-- -->

Confused about how to make purrr work with more complicated problems?
Hadley Wickham’s trick is apparently to paste code for a single element
into purrr functions. Similar to subsetting data for a test piece, but
define your objects and write your code snippets exactly as they would
be within purrr (or a loop) rather than using intermediate variables and
then re-writing it all into a function after Here, we want to do
something (use the `n_distinct` and `class` functions) across multiple
columns in gapminder. So we will start by working with only one element:
which is one column of the gapminder data frame.

``` r
#Define one element: the first column of gapminder
  #Note that is is defined in the SAME WAY as I would use inside the map_df() function I want to use
  #I am NOT using intermediate non-purrr (or for loop) code which I am then transforming back into a loop or purrr
.x <- gapminder %>% pluck(1)
head(.x)
```

    ## [1] Afghanistan Afghanistan Afghanistan Afghanistan Afghanistan Afghanistan
    ## 142 Levels: Afghanistan Albania Algeria Angola Argentina Australia ... Zimbabwe

``` r
#Then create a data frame for this column that contains what you want (n_distinct and class)
data.frame(unique_values = n_distinct(.x),
           column_class = class(.x))
```

    ##   unique_values column_class
    ## 1           142       factor

``` r
#The step above did return what I wanted, so can now just paste into the map_df() function
  #in this case, we'll use the tilda-dot shorthand for anonymous functions
gapminder %>% map_df(~(data.frame(unique_values = n_distinct(.x),
                                 column_class = class(.x))),
                      .id = "variable_name")
```

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector
    
    ## Warning in bind_rows_(x, .id): binding character and factor vector, coercing
    ## into character vector

    ##   variable_name unique_values column_class
    ## 1       country           142       factor
    ## 2     continent             5       factor
    ## 3          year            12      integer
    ## 4       lifeExp          1626      numeric
    ## 5           pop          1704      integer
    ## 6     gdpPercap          1704      numeric

``` r
#Much rejoicing
```

For a more complicated example, let’s look at how to print a bunch of
histogram plots, each with breaks that make sense.

``` r
#Define a list of functions
f <- list(Normal = "rnorm",
          Uniform = "runif",
          Exp = "rexp")

#Define parameters
params <- list(Normal = list(mean = 10),
               Uniform = list(min = 0, max = 5),
               Exp = list(rate = 5))

#Assigne the simulated samples to sims object
sims <- invoke_map(f, params, n = 1000)

#See intermediate result: use walk() to make a histogram of each element in sims...it's ugly but works!
walk(sims, hist)
```

![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-1.png)<!-- -->![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-2.png)<!-- -->![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-3.png)<!-- -->

``` r
#Define a function to make nice breaks on a histogram
find_breaks <- function(x){
  rng <- range(x, na.rm = T)
  seq(rng[1], rng[2], length.out = 30)
}

#Use map() to iterate find_breaks over sims
nice_breaks <- map(sims, find_breaks)

#Then use nice_breaks as the second argument to walk2()
walk2(sims, nice_breaks, hist)
```

![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-4.png)<!-- -->![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-5.png)<!-- -->![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-6.png)<!-- -->

``` r
  #Nice breaks but UGLY lables...let's fix this

#Use pwalk to make nice lables and titles
  #like pmap, the first argument needs to be a LIST
nice_titles <- c("Normal(10, 1", "Uniform(0, 5)", "Exp(5)")

pwalk(list(x = sims,
           breaks = nice_breaks,
           main = nice_titles),
      hist,
      xlab = "") #Note that xlab is outside the list of arguments being iterated over as its the same value for all 3 histograms
```

![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-7.png)<!-- -->![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-8.png)<!-- -->![](writing_functions_MC_files/figure-gfm/Walk%20and%20histogram%20plots%20with%20nice%20breaks-9.png)<!-- -->

**Nested data frames**: Recall that columns in tibbles can be lists -
this is useful as it allows tibbles to become ‘nested’, meaning they are
split into separate data frames based on a grouping variable. Each of
those nested data frames are stored as elements of a list (within the
`data` column).

``` r
# Example of how nested data frames work
gpm_nested <- gapminder %>% 
                group_by(continent) %>% 
                nest()
gpm_nested
```

    ## # A tibble: 5 x 2
    ## # Groups:   continent [5]
    ##   continent data              
    ##   <fct>     <list>            
    ## 1 Asia      <tibble [396 × 5]>
    ## 2 Europe    <tibble [360 × 5]>
    ## 3 Africa    <tibble [624 × 5]>
    ## 4 Americas  <tibble [300 × 5]>
    ## 5 Oceania   <tibble [24 × 5]>

``` r
# How to extract the data on the first continent (Asia)?
#Method1 - square brackets
gpm_nested$data[[1]]
```

    ## # A tibble: 396 x 5
    ##    country      year lifeExp      pop gdpPercap
    ##    <fct>       <int>   <dbl>    <int>     <dbl>
    ##  1 Afghanistan  1952    28.8  8425333      779.
    ##  2 Afghanistan  1957    30.3  9240934      821.
    ##  3 Afghanistan  1962    32.0 10267083      853.
    ##  4 Afghanistan  1967    34.0 11537966      836.
    ##  5 Afghanistan  1972    36.1 13079460      740.
    ##  6 Afghanistan  1977    38.4 14880372      786.
    ##  7 Afghanistan  1982    39.9 12881816      978.
    ##  8 Afghanistan  1987    40.8 13867957      852.
    ##  9 Afghanistan  1992    41.7 16317921      649.
    ## 10 Afghanistan  1997    41.8 22227415      635.
    ## # … with 386 more rows

``` r
#Method2 - pluck
gpm_nested %>% pluck("data", 1) #This says to extract the first entry from the first data column
```

    ## # A tibble: 396 x 5
    ##    country      year lifeExp      pop gdpPercap
    ##    <fct>       <int>   <dbl>    <int>     <dbl>
    ##  1 Afghanistan  1952    28.8  8425333      779.
    ##  2 Afghanistan  1957    30.3  9240934      821.
    ##  3 Afghanistan  1962    32.0 10267083      853.
    ##  4 Afghanistan  1967    34.0 11537966      836.
    ##  5 Afghanistan  1972    36.1 13079460      740.
    ##  6 Afghanistan  1977    38.4 14880372      786.
    ##  7 Afghanistan  1982    39.9 12881816      978.
    ##  8 Afghanistan  1987    40.8 13867957      852.
    ##  9 Afghanistan  1992    41.7 16317921      649.
    ## 10 Afghanistan  1997    41.8 22227415      635.
    ## # … with 386 more rows

This means we can use dplyr functions on much more complex
objects\!\!\!\!\! However, we need to do this is a specific way. The
issue with nested data frames is that *vectorized functions* (e.g.,
`dplyr::mutate`, `dplyr::rename`, `dplyr::distinct`) don’t work on
lists\! So in order to use mutate on list-columns, you need to wrap the
function you want to apply in a map function.

``` r
#This works, as it is a data frame and columns are vectors
tibble(vec_col = 1:10) %>% 
  mutate(vec_sum = sum(vec_col))
```

    ## # A tibble: 10 x 2
    ##    vec_col vec_sum
    ##      <int>   <int>
    ##  1       1      55
    ##  2       2      55
    ##  3       3      55
    ##  4       4      55
    ##  5       5      55
    ##  6       6      55
    ##  7       7      55
    ##  8       8      55
    ##  9       9      55
    ## 10      10      55

``` r
#This does not work as columns are lists
# tibble(list_col = list(c(1, 5, 7),
#                        5,
#                        c(10, 10, 11))) %>% 
#   mutate(list_sum = sum(list_col))
  #Can't knit with the above in, as it throws an error

#This works on list-columns, as the dplyr::sum function is wrapped in a map function
  #Note that because we are using `map` we get a list returned
  #But if we used `map_dbl` we could get a numeric vector output
tibble(list_col = list(c(1, 5, 7),
                       5,
                       c(10, 10, 11))) %>% 
  mutate(list_sum = map(list_col, sum)) %>% 
  pull(list_sum)
```

    ## [[1]]
    ## [1] 13
    ## 
    ## [[2]]
    ## [1] 5
    ## 
    ## [[3]]
    ## [1] 31

So when could this be more useful? Perhaps for statistical or data
exploration purposes\! The example Rebecca Barter provided is for
fitting a linear regression model to each continent and evaluating it
within a single tibble.

``` r
### Method 1: Seperating out each continent
# Nest gapminder
gmp_nested <- gapminder %>% 
                group_by(continent) %>% 
                nest()

# Fit a model separately for each continent
gmp_nested <- gmp_nested %>% 
                mutate(lm_obj = map(data, ~lm(lifeExp ~ pop + gdpPercap + year, data = .x)))

#let's see what we have now
gmp_nested
```

    ## # A tibble: 5 x 3
    ## # Groups:   continent [5]
    ##   continent data               lm_obj
    ##   <fct>     <list>             <list>
    ## 1 Asia      <tibble [396 × 5]> <lm>  
    ## 2 Europe    <tibble [360 × 5]> <lm>  
    ## 3 Africa    <tibble [624 × 5]> <lm>  
    ## 4 Americas  <tibble [300 × 5]> <lm>  
    ## 5 Oceania   <tibble [24 × 5]>  <lm>

``` r
gmp_nested %>% pluck("lm_obj", 1)
```

    ## 
    ## Call:
    ## lm(formula = lifeExp ~ pop + gdpPercap + year, data = .x)
    ## 
    ## Coefficients:
    ## (Intercept)          pop    gdpPercap         year  
    ##  -7.833e+02    4.228e-11    2.510e-04    4.251e-01

``` r
# Predict the response for each continent
  #We need to use map2 as in order to predict we need to use the response variable stored in the `data` column and use the linear model
  #So we have 2 objects we need to iterate over: the data and the linear model objet
gmp_nested <- gmp_nested %>% 
                mutate(pred = map2(lm_obj, data, function(.lm, .data) predict(.lm, .data)))

#let's see what we have now
gmp_nested
```

    ## # A tibble: 5 x 4
    ## # Groups:   continent [5]
    ##   continent data               lm_obj pred       
    ##   <fct>     <list>             <list> <list>     
    ## 1 Asia      <tibble [396 × 5]> <lm>   <dbl [396]>
    ## 2 Europe    <tibble [360 × 5]> <lm>   <dbl [360]>
    ## 3 Africa    <tibble [624 × 5]> <lm>   <dbl [624]>
    ## 4 Americas  <tibble [300 × 5]> <lm>   <dbl [300]>
    ## 5 Oceania   <tibble [24 × 5]>  <lm>   <dbl [24]>

``` r
# Calculate the correlation between the observed and the predicted response for each continent
gmp_nested <- gmp_nested %>% 
                mutate(cor = map2_dbl(pred, data, function(.pred, .data) cor(.pred, .data$lifeExp)))

#let's see what we have now
gmp_nested
```

    ## # A tibble: 5 x 5
    ## # Groups:   continent [5]
    ##   continent data               lm_obj pred          cor
    ##   <fct>     <list>             <list> <list>      <dbl>
    ## 1 Asia      <tibble [396 × 5]> <lm>   <dbl [396]> 0.723
    ## 2 Europe    <tibble [360 × 5]> <lm>   <dbl [360]> 0.834
    ## 3 Africa    <tibble [624 × 5]> <lm>   <dbl [624]> 0.645
    ## 4 Americas  <tibble [300 × 5]> <lm>   <dbl [300]> 0.779
    ## 5 Oceania   <tibble [24 × 5]>  <lm>   <dbl [24]>  0.987

``` r
### Method 2 - fit a separate linear model WITHOUT spliting the data
  #So we want ONE data frame that has the continent, earch term in the model, its linear model coefficient estimate, and standard error
gapminder %>% 
  group_by(continent) %>% 
  nest() %>% 
  #Remember that in a nested tibble, the data for each continent is stored under the 'data' list-column
  mutate(lm_obj = map(data, ~lm(lifeExp ~ pop + year + gdpPercap, data = .))) %>% 
  mutate(lm_tidy = map(lm_obj, broom::tidy)) %>% 
  ungroup() %>% 
  transmute(continent, lm_tidy) %>% 
  unnest(cols = c(lm_tidy))
```

    ## # A tibble: 20 x 6
    ##    continent term         estimate std.error statistic  p.value
    ##    <fct>     <chr>           <dbl>     <dbl>     <dbl>    <dbl>
    ##  1 Asia      (Intercept) -7.83e+ 2   4.83e+1  -16.2    1.22e-45
    ##  2 Asia      pop          4.23e-11   2.04e-9    0.0207 9.83e- 1
    ##  3 Asia      year         4.25e- 1   2.44e-2   17.4    1.13e-50
    ##  4 Asia      gdpPercap    2.51e- 4   3.01e-5    8.34   1.31e-15
    ##  5 Europe    (Intercept) -1.61e+ 2   2.28e+1   -7.09   7.44e-12
    ##  6 Europe    pop         -8.18e- 9   7.80e-9   -1.05   2.95e- 1
    ##  7 Europe    year         1.16e- 1   1.16e-2    9.96   8.88e-21
    ##  8 Europe    gdpPercap    3.25e- 4   2.15e-5   15.2    2.21e-40
    ##  9 Africa    (Intercept) -4.70e+ 2   3.39e+1  -13.9    2.17e-38
    ## 10 Africa    pop         -3.68e- 9   1.89e-8   -0.195  8.45e- 1
    ## 11 Africa    year         2.61e- 1   1.71e-2   15.2    1.07e-44
    ## 12 Africa    gdpPercap    1.12e- 3   1.01e-4   11.1    2.46e-26
    ## 13 Americas  (Intercept) -5.33e+ 2   4.10e+1  -13.0    6.40e-31
    ## 14 Americas  pop         -2.15e- 8   8.62e-9   -2.49   1.32e- 2
    ## 15 Americas  year         3.00e- 1   2.08e-2   14.4    3.79e-36
    ## 16 Americas  gdpPercap    6.75e- 4   7.15e-5    9.44   1.13e-18
    ## 17 Oceania   (Intercept) -2.10e+ 2   5.12e+1   -4.10   5.61e- 4
    ## 18 Oceania   pop          8.37e- 9   3.34e-8    0.251  8.05e- 1
    ## 19 Oceania   year         1.42e- 1   2.65e-2    5.34   3.19e- 5
    ## 20 Oceania   gdpPercap    2.03e- 4   8.47e-5    2.39   2.66e- 2

``` r
# WOW!!!!!
```

**Dealing with failure in purrr**:

*Put in stuff about using safely(), possibly(), and quietly() to deal
with failure in purrr from Data camp*
