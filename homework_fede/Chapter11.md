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

``` r
library(gapminder)
```

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

### 11.4.4 Collapse a vector

You can collapse a vector to a single string usinh str\_c. This command can also be used to create a caracter vector by catenating multiple vectors (using sep).

Element-wise catenation can be combined with collapsing.

If the to-be-combined vectors are variables in a data frame, you can use tidyr::unite() to make a single new variable from them.

``` r
head(fruit) %>% str_c(collapse = "; ")
```

    ## [1] "apple; apricot; avocado; banana; bell pepper; bilberry"

``` r
str_c(fruit[1:4], fruit[5:8], sep = " & ")
```

    ## [1] "apple & bell pepper"   "apricot & bilberry"    "avocado & blackberry" 
    ## [4] "banana & blackcurrant"

``` r
str_c(fruit[1:4], fruit[5:8], sep = " & ", collapse = ", ")
```

    ## [1] "apple & bell pepper, apricot & bilberry, avocado & blackberry, banana & blackcurrant"

``` r
fruit_df <- tibble(fruit1 = fruit[1:4], fruit2 = fruit[5:8])

fruit_df %>% unite("Combo", fruit1, fruit2, sep = " & ")
```

    ## # A tibble: 4 x 1
    ##   Combo                
    ##   <chr>                
    ## 1 apple & bell pepper  
    ## 2 apricot & bilberry   
    ## 3 avocado & blackberry 
    ## 4 banana & blackcurrant

### 11.4.6 Substring replacement

Str\_replace() can ber used to replace and explicit string.

A special case that comes up a lot is replacing NA, for which there is str\_replace\_na().

If the NA-afflicted variable lives in a data frame, you can use tidyr::replace\_na().

``` r
my_fruit %>% str_replace(pattern = "fruit", replacement = "DELI")
```

    ## [1] "breadDELI"   "dragonDELI"  "grapeDELI"   "jackDELI"    "kiwi DELI"  
    ## [6] "passionDELI" "star DELI"   "ugli DELI"

``` r
melons <- str_subset(fruit, pattern = "melon")
melons[2] <- NA
melons
```

    ## [1] "canary melon" NA             "watermelon"

``` r
str_replace_na(melons, replacement = "Melon desconocido")
```

    ## [1] "canary melon"      "Melon desconocido" "watermelon"

``` r
tibble(melons) %>% replace_na(replace = list(melons = "Melon desconocido"))
```

    ## # A tibble: 3 x 1
    ##   melons           
    ##   <chr>            
    ## 1 canary melon     
    ## 2 Melon desconocido
    ## 3 watermelon

### 11.5 Examples with gapminder

Storing the gapminder countries levels. To have a list of all the variables but ot actually saving the country variable.

``` r
countries <- levels(gapminder$country)
```

### 11.5.2 Characters with special meaning

Frequently your string tasks cannot be expressed in terms of a fixed string, but can be described in terms of a pattern. Regular expressions, aka “regexes”, are the standard way to specify these patterns. In regexes, specific characters and constructs take on special meaning in order to match multiple strings.

The first metacharacter is the period ., which stands for any single character, except a newline (which by the way, is represented by ). The regex a.b will match all countries that have an a, followed by any single character, followed by b. Yes, regexes are case sensitive, i.e. “Italy” does not match.

``` r
str_subset(countries, pattern = "i.a")
```

    ##  [1] "Argentina"                "Bosnia and Herzegovina"  
    ##  [3] "Burkina Faso"             "Central African Republic"
    ##  [5] "China"                    "Costa Rica"              
    ##  [7] "Dominican Republic"       "Hong Kong, China"        
    ##  [9] "Jamaica"                  "Mauritania"              
    ## [11] "Nicaragua"                "South Africa"            
    ## [13] "Swaziland"                "Taiwan"                  
    ## [15] "Thailand"                 "Trinidad and Tobago"

Anchors can be included to express where the expression must occur within the string. The ^ indicates the beginning of string and $ indicates the end.

Note how the regex i.a$ matches many fewer countries than i.a alone. Likewise, more elements of my\_fruit match d than ^d, which requires “d” at string start.

The metacharacter indicates a word boundary and indicates NOT a word boundary. This is our first encounter with something called “escaping” and right now I just want you at accept that we need to prepend a second backslash to use these sequences in regexes in R. We’ll come back to this tedious point later.

``` r
str_subset(countries, pattern = "i.a$")
```

    ## [1] "Argentina"              "Bosnia and Herzegovina" "China"                 
    ## [4] "Costa Rica"             "Hong Kong, China"       "Jamaica"               
    ## [7] "South Africa"

``` r
str_subset(my_fruit, pattern = "d")
```

    ## [1] "breadfruit"  "dragonfruit"

``` r
str_subset(my_fruit, pattern = "^d")
```

    ## [1] "dragonfruit"

``` r
str_subset(fruit, pattern = "melon")
```

    ## [1] "canary melon" "rock melon"   "watermelon"

``` r
str_subset(fruit, pattern = "\\bmelon")
```

    ## [1] "canary melon" "rock melon"

``` r
str_subset(fruit, pattern = "\\Bmelon")
```

    ## [1] "watermelon"

11.5.3 Character classes

Characters can be specified via classes. You can make them explicitly “by hand” or use some pre-existing ones. The 2014 STAT 545 regex lesson (Appendix A) has a good list of character classes. Character classes are usually given inside square brackets, \[\] but a few come up so often that we have a metacharacter for them, such as for a single digit.

Here we match ia at the end of the country name, preceded by one of the characters in the class. Or, in the negated class, preceded by anything but one of those characters.

Here we revisit splitting my\_fruit with two more general ways to match whitespace: the metacharacter and the POSIX class \[:space:\]. Notice that we must prepend an extra backslash  to escape and the POSIX class has to be surrounded by two sets of square brackets.THREE DIFFERNT WAYS TO OBTAIN SAME RESULT

``` r
str_subset(countries, pattern = "[nls]ia$")
```

    ##  [1] "Albania"    "Australia"  "Indonesia"  "Malaysia"   "Mauritania"
    ##  [6] "Mongolia"   "Romania"    "Slovenia"   "Somalia"    "Tanzania"  
    ## [11] "Tunisia"

``` r
#In this case the [nls] are the characters behind ia, we are looking for in the list

str_subset(countries, pattern = "[^nls]ia$")
```

    ##  [1] "Algeria"      "Austria"      "Bolivia"      "Bulgaria"     "Cambodia"    
    ##  [6] "Colombia"     "Croatia"      "Ethiopia"     "Gambia"       "India"       
    ## [11] "Liberia"      "Namibia"      "Nigeria"      "Saudi Arabia" "Serbia"      
    ## [16] "Syria"        "Zambia"

``` r
#with the ^ we negate that class and obtain all the countries ending in ia, but previous character not n, l, ors

str_split_fixed(my_fruit, pattern = " ", n = 2)
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
## Two alternatives
str_split_fixed(my_fruit, pattern = "\\s", n = 2)
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
str_split_fixed(my_fruit, pattern = "[[:space:]]", n = 2)
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

### 11.5.4 Quantifiers

Missing to make a table of this info quantifier meaning quantifier meaning \* 0 or more {n} exactly n + 1 or more {n,} at least n ? 0 or 1 {,m} at most m {n,m} between n and m, inclusive

Explore these by inspecting matches for l followed by e, allowing for various numbers of characters in between.

l.\*e will match strings with 0 or more characters in between, i.e. any string with an l eventually followed by an e. This is the most inclusive regex for this example, so we store the result as matches to use as a baseline for comparison.(Curiious note: If I put the variable matches in () it prints it)

Change the quantifier from \* to + to require at least one intervening character. The strings that no longer match: all have a literal le with no preceding l and no following e. Intersect() find those that follow a pattern and setdiff() those that don't

``` r
(matches<- str_subset(fruit, pattern = "l.*e"))
```

    ##  [1] "apple"             "bell pepper"       "bilberry"         
    ##  [4] "blackberry"        "blood orange"      "blueberry"        
    ##  [7] "cantaloupe"        "chili pepper"      "clementine"       
    ## [10] "cloudberry"        "elderberry"        "huckleberry"      
    ## [13] "lemon"             "lime"              "lychee"           
    ## [16] "mulberry"          "olive"             "pineapple"        
    ## [19] "purple mangosteen" "salal berry"

``` r
list(match = intersect(matches, str_subset(fruit, pattern = "l.+e")),
     no_match = setdiff(matches, str_subset(fruit, pattern = "l.+e")))
```

    ## $match
    ##  [1] "bell pepper"       "bilberry"          "blackberry"       
    ##  [4] "blood orange"      "blueberry"         "cantaloupe"       
    ##  [7] "chili pepper"      "clementine"        "cloudberry"       
    ## [10] "elderberry"        "huckleberry"       "lime"             
    ## [13] "lychee"            "mulberry"          "olive"            
    ## [16] "purple mangosteen" "salal berry"      
    ## 
    ## $no_match
    ## [1] "apple"     "lemon"     "pineapple"

Change the quantifier from \* to ? to require at most one intervening character. In the strings that no longer match, the shortest gap between l and following e is at least two characters.

Finally, we remove the quantifier and allow for no intervening characters. The strings that no longer match lack a literal le.

``` r
list(match = intersect(matches, str_subset(fruit, pattern = "l.?e")),
     no_match = setdiff(matches, str_subset(fruit, pattern = "l.?e")))
```

    ## $match
    ##  [1] "apple"             "bilberry"          "blueberry"        
    ##  [4] "clementine"        "elderberry"        "huckleberry"      
    ##  [7] "lemon"             "mulberry"          "pineapple"        
    ## [10] "purple mangosteen"
    ## 
    ## $no_match
    ##  [1] "bell pepper"  "blackberry"   "blood orange" "cantaloupe"   "chili pepper"
    ##  [6] "cloudberry"   "lime"         "lychee"       "olive"        "salal berry"

``` r
list(match = intersect(matches, str_subset(fruit, pattern = "le")),
     no_match = setdiff(matches, str_subset(fruit, pattern = "le")))
```

    ## $match
    ## [1] "apple"             "clementine"        "huckleberry"      
    ## [4] "lemon"             "pineapple"         "purple mangosteen"
    ## 
    ## $no_match
    ##  [1] "bell pepper"  "bilberry"     "blackberry"   "blood orange" "blueberry"   
    ##  [6] "cantaloupe"   "chili pepper" "cloudberry"   "elderberry"   "lime"        
    ## [11] "lychee"       "mulberry"     "olive"        "salal berry"

11.5.5 Escaping

You’ve probably caught on by now that there are certain characters with special meaning in regexes, including $ \* + . ? \[ \] ^ { } | ( ) . What if you really need the plus sign to be a literal plus sign and not a regex quantifier? You will need to escape it by prepending a backslash. But wait … there’s more! Before a regex is interpreted as a regular expression, it is also interpreted by R as a string. And backslash is used to escape there as well. So, in the end, you need to preprend two backslashes in order to match a literal plus sign in a regex.

This will be more clear with examples!

``` r
cat("Do you use \"airquotes\" much?")
```

    ## Do you use "airquotes" much?

``` r
cat("before the newline\nafter the newline")
```

    ## before the newline
    ## after the newline

``` r
cat("before the tab\tafter the tab")
```

    ## before the tab   after the tab

### 11.5.5.2 Escapes in regular expressions

We know several gapminder country names contain a period. How do we isolate them? Although it’s tempting, this command str\_subset(countries, pattern = ".") won’t work! (You need to ESCAPE)

``` r
## cheating using a POSIX class ;)
str_subset(countries, pattern = "[[:punct:]]")
```

    ## [1] "Congo, Dem. Rep." "Congo, Rep."      "Cote d'Ivoire"    "Guinea-Bissau"   
    ## [5] "Hong Kong, China" "Korea, Dem. Rep." "Korea, Rep."      "Yemen, Rep."

``` r
## using two backslashes to escape the period
str_subset(countries, pattern = "\\.")
```

    ## [1] "Congo, Dem. Rep." "Congo, Rep."      "Korea, Dem. Rep." "Korea, Rep."     
    ## [5] "Yemen, Rep."

``` r
##A last example that matches an actual square bracket.
(x <- c("whatever", "X is distributed U[0,1]"))
```

    ## [1] "whatever"                "X is distributed U[0,1]"

``` r
str_subset(x, pattern = "\\[" )
```

    ## [1] "X is distributed U[0,1]"
