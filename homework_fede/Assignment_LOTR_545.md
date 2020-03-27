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

lord_tidy2 <- lord_bind_MF %>% pivot_longer(cols = c(Elf, Hobbit, Man), names_to = "Race", values_to = "Words") %>% 
                select(Film, Race, Gender, Words) %>% 
                arrange(Film, Race, Gender)
```

``` r
lord_tidy2 %>% pivot_wider(names_from = Race, values_from = Words )
```

    ## # A tibble: 6 x 5
    ##   Film                       Gender   Elf Hobbit   Man
    ##   <chr>                      <chr>  <dbl>  <dbl> <dbl>
    ## 1 The Fellowship Of The Ring Female  1229     14     0
    ## 2 The Fellowship Of The Ring Male     971   3644  1995
    ## 3 The Return Of The King     Female   183      2   268
    ## 4 The Return Of The King     Male     510   2673  2459
    ## 5 The Two Towers             Female   331      0   401
    ## 6 The Two Towers             Male     513   2463  3589

``` r
lord_tidy2 %>% pivot_wider(names_from = Gender, values_from = Words )
```

    ## # A tibble: 9 x 4
    ##   Film                       Race   Female  Male
    ##   <chr>                      <chr>   <dbl> <dbl>
    ## 1 The Fellowship Of The Ring Elf      1229   971
    ## 2 The Fellowship Of The Ring Hobbit     14  3644
    ## 3 The Fellowship Of The Ring Man         0  1995
    ## 4 The Return Of The King     Elf       183   510
    ## 5 The Return Of The King     Hobbit      2  2673
    ## 6 The Return Of The King     Man       268  2459
    ## 7 The Two Towers             Elf       331   513
    ## 8 The Two Towers             Hobbit      0  2463
    ## 9 The Two Towers             Man       401  3589

``` r
lord_unite <- lord_tidy2 %>% unite("Race_Gender", Race, Gender) %>% 
  pivot_wider(names_from = Race_Gender, values_from = Words )
```
