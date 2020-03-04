Lord of the Rings
================
Federico Andrade-Rivas
March 1, 2020

### R Markdown

### Bidding all the datasets

``` r
lord_untidy <- bind_rows(f_lord, two_lord, r_lord)
str(lord_untidy)
```

    ## Classes 'spec_tbl_df', 'tbl_df', 'tbl' and 'data.frame': 9 obs. of  4 variables:
    ##  $ Film  : chr  "The Fellowship Of The Ring" "The Fellowship Of The Ring" "The Fellowship Of The Ring" "The Two Towers" ...
    ##  $ Race  : chr  "Elf" "Hobbit" "Man" "Elf" ...
    ##  $ Female: num  1229 14 0 331 0 ...
    ##  $ Male  : num  971 3644 1995 513 2463 ...

### Tiddy untidy data set. I used pivot\_longer as it was recommended. More functionaluity

``` r
lord_tidy <- lord_untidy %>% pivot_longer(cols = c(Female, Male), names_to = "Gender", values_to = "Words") %>% 
  arrange(Film, Race, Gender)
```

``` r
write_csv(lord_tidy, "lotr_tidy2.csv")
```

### Exercises Female and Male databases

``` r
female <- read_csv(file.path("Assignment_LOTR_545_files", "lotr-tidy-master", "data", "Female.csv"))
```

    ## Parsed with column specification:
    ## cols(
    ##   Gender = col_character(),
    ##   Film = col_character(),
    ##   Elf = col_double(),
    ##   Hobbit = col_double(),
    ##   Man = col_double()
    ## )

``` r
male <- read_csv(file.path("Assignment_LOTR_545_files", "lotr-tidy-master", "data", "Male.csv")) 
```

    ## Parsed with column specification:
    ## cols(
    ##   Gender = col_character(),
    ##   Film = col_character(),
    ##   Elf = col_double(),
    ##   Hobbit = col_double(),
    ##   Man = col_double()
    ## )

``` r
lord_bind_MF <- bind_rows(female, male)

lord_bind_MF %>% pivot_longer(cols = c(Elf, Hobbit, Man), names_to = "Race", values_to = "Words") %>% 
                select(Film, Race, Gender, Words) %>% 
                arrange(Film, Race, Gender)
```

    ## # A tibble: 18 x 4
    ##    Film                       Race   Gender Words
    ##    <chr>                      <chr>  <chr>  <dbl>
    ##  1 The Fellowship Of The Ring Elf    Female  1229
    ##  2 The Fellowship Of The Ring Elf    Male     971
    ##  3 The Fellowship Of The Ring Hobbit Female    14
    ##  4 The Fellowship Of The Ring Hobbit Male    3644
    ##  5 The Fellowship Of The Ring Man    Female     0
    ##  6 The Fellowship Of The Ring Man    Male    1995
    ##  7 The Return Of The King     Elf    Female   183
    ##  8 The Return Of The King     Elf    Male     510
    ##  9 The Return Of The King     Hobbit Female     2
    ## 10 The Return Of The King     Hobbit Male    2673
    ## 11 The Return Of The King     Man    Female   268
    ## 12 The Return Of The King     Man    Male    2459
    ## 13 The Two Towers             Elf    Female   331
    ## 14 The Two Towers             Elf    Male     513
    ## 15 The Two Towers             Hobbit Female     0
    ## 16 The Two Towers             Hobbit Male    2463
    ## 17 The Two Towers             Man    Female   401
    ## 18 The Two Towers             Man    Male    3589
