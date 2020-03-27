Chapter 12
================
Federico Andrade-Rivas
March 19, 2020

Chapter 12 Character Encoding
-----------------------------

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

### 12.2 Character Encoding

The encoding of a string defines this relationship: encoding is a map between one or more bytes and a displayable character.

``` r
charToRaw("hello!")
```

    ## [1] 68 65 6c 6c 6f 21

``` r
as.integer(charToRaw("hello!"))
```

    ## [1] 104 101 108 108 111  33

``` r
charToRaw("hellṏ!")
```

    ## [1] 68 65 6c 6c e1 b9 8f 21

``` r
as.integer(charToRaw("hellṏ!"))
```

    ## [1] 104 101 108 108 225 185 143  33

-   Encode translates a string to another encoding. We’ve used iconv(x, from = "UTF-8", to = <DIFFERENT_ENCODING>) here.

-   bytes shows the bytes that make up a string. We’ve used charToRaw(), which returns hexadecimal in R. For the sake of comparison to the Ruby post, I’ve converted to decimal with as.integer().

-   force\_encoding shows what the input bytes would look like if interpreted by a different encoding. We’ve used iconv(x, from = <DIFFERENT_ENCODING>, to = "UTF-8").

### 12.4 A three-step process for fixing encoding bugs

#### 12.4.1 Discover which encoding your string is actually in

``` r
string <- "hi\x99!"

Encoding(string)
```

    ## [1] "unknown"

``` r
stringi::stri_enc_detect(string)
```

    ## [[1]]
    ##   Encoding Language Confidence
    ## 1 UTF-16BE                 0.1
    ## 2 UTF-16LE                 0.1
    ## 3   EUC-JP       ja        0.1
    ## 4   EUC-KR       ko        0.1

#### 12.4.2 Decide which enconding you want

EASY: UFT-8...DONE!

#### 12.4.3 Re-encode your string

``` r
string_windows <- "hi\x99!"
string_utf8 <- iconv(string_windows, from = "Windows-1252", to = "UTF-8")
Encoding(string_utf8)
```

    ## [1] "UTF-8"

### 12.5 How to Get From Theyâ€™re to They’re

The string has 7 characters, but 9 bytes, because we’re using 3 bytes to represent the curly single quote. Let’s focus just on that. Ruby

One of the most common encoding fiascos you’ll see is this: theyâ€™re. Note that the curly single quote has been turned into a 3 character monstrosity. This is no coincidence. Remember those 3 bytes? This is what happens when you interpret bytes that represent text in the UTF-8 encoding as if it’s encoded as Windows-1252. Learn to recognize it. Ruby

``` r
string_curly <- "they’re"
charToRaw(string_curly)
```

    ## [1] 74 68 65 79 e2 80 99 72 65

``` r
as.integer(charToRaw(string_curly))
```

    ## [1] 116 104 101 121 226 128 153 114 101

``` r
length(as.integer(charToRaw(string_curly)))
```

    ## [1] 9

``` r
nchar(string_curly)
```

    ## [1] 7

``` r
(string_mis_encoded <- iconv(string_curly, to = "UTF-8", from = "windows-1252"))
```

    ## [1] "theyâ€™re"

Let’s review the original, correct bytes vs. the current, incorrect bytes and print the associated strings.

``` r
as.integer(charToRaw(string_curly))
```

    ## [1] 116 104 101 121 226 128 153 114 101

``` r
as.integer(charToRaw(string_mis_encoded))
```

    ##  [1] 116 104 101 121 195 162 226 130 172 226 132 162 114 101

``` r
string_curly
```

    ## [1] "they’re"

``` r
string_mis_encoded
```

    ## [1] "theyâ€™re"
