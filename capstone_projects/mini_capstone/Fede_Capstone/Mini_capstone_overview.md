Add column function mini-capstone project
================
Michelle Coombe
2020-06-28

This was my first function for my dataset, so I thought I would share it
as a starting point for our other capstone projects.

## Background of data

My avian influenza data comes from multiple spreadsheets and sources.
One thing I seem to be constantly doing in multiple files is adding a
column indicating the date of collection by label indicating the month
and year (mon-yr). This allows me to plot the data nicely (as the data
was collected monthly-ish over the course of two years) but also lets me
split up the data based on specific mon-yr(s) when I am trying to
explore the data (or find mistakes\!). Since I was doing this repeately
on different datasets, and as making this type of column isn’t already
captured by a tidyverse function, I thought this would be a great
opportunity to write my own function. As it also uses date class
objects, I thought it would simulateously be a good review of our data
wrangling methods for dates that we learnt earlier in the year. As a
bonus (at least for me) I tried to apply this function to my dataset
using ‘purrr’ package as I need practice with this.

## Capstone project goals

The goals for this project are:

1.  Turn the date column into a ‘Date’ class, using lubridate.

2.  Write a function to add a column for mon-yr (“add\_monyr” function).
    Then apply the function to the dataset to make the extra column
    **without** using `purrr`. (i.e., either write this within the
    function itself or use base functions like lapply or sapply)

<!-- end list -->

  - This column will be a factor of the month (using the abbreviated
    label) seperated from the year with a dash. For example, Jan-2018 or
    Sep-2017.
  - As I want to plot this in ggplot based on calendar time (rather than
    alphabetical order) this column also needs to be an ordered factor.
    Therefore, the reference level will be your earliest mon-yr (e.g.,
    Sep-2016), then progress sequentially (e.g., then Oct-2016,
    Nov-2016, etc).

<!-- end list -->

3.  Bonus (or instead of \#3 if you find it easier) - apply your
    function to the dataset to make the extra column **WITH `purrr`**.

<!-- end list -->

  - This may or may not require modifying your function from Goal 2,
    depending on how you have written it.
  - There are some examples of how to use ‘purrr’ that I put in the
    ‘hints’ R script that I found helpful for thinking through this
    step.

## Overview of files

The starting point for working on this problem is in the
[add\_column\_start](capstone_projects/mini_capstone/add_column_start.R)
script. This contains the data, the packages you will need, and some
headers for steps.

There is a hints
[file](capstone_projects/mini_capstone/add_column_hints.R) that contains
the code I run line by line of each individual dataset used to make the
mon\_yr column (i.e., my non-function solution to this problem). You
should be able to take these working snippets of code to turn them into
a function. Additionally, this has some examples on using `purrr` from
Rebecca Barter’s
[blog](http://www.rebeccabarter.com/blog/2019-08-19_purrr/) that I found
helpful.

My current solution to goals 1 to 4 is in the
[add\_column\_full](capstone_projects/mini_capstone/add_column_full.R)
file. I would love to see if you have found better alternative
solutions\!\!
