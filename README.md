
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Open Scoring API Client for R

<!-- badges: start -->

[![R-CMD-check](https://github.com/jakub-jedrusiak/openscoring/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jakub-jedrusiak/openscoring/actions/workflows/R-CMD-check.yaml)
![CRAN/METACRAN Version](https://img.shields.io/cran/v/openscoring)
<!-- badges: end -->

Creativity research involves the need to score open-ended problems.
Usually done by humans, automatic scoring using AI becomes more and more
accurate. This package provides a simple interface to the ‘Open Scoring’
API, leading creativity scoring technology by Organiscak et
al. ([2023](https://doi.org/10.1016/j.tsc.2023.101356)). With it, you
can score your own data directly from an R script.

## Installation

Install the released version of openscoring from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("openscoring")
```

You can install the development version of openscoring from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jakub-jedrusiak/openscoring")
```

## Example

``` r
library(openscoring)

df <- tibble::tibble(
  stimulus = c("brick", "hammer", "sponge"),
  response = c("butter for trolls", "make Thor jeallous", "make it play in a kids show")
)

df
#> # A tibble: 3 × 2
#>   stimulus response                   
#>   <chr>    <chr>                      
#> 1 brick    butter for trolls          
#> 2 hammer   make Thor jeallous         
#> 3 sponge   make it play in a kids show

scored_df <- oscai(df, stimulus, response, model = "davinci2")
#> ✔ Remember to cite:
#> 
#> Organisciak, P., Dumas, D., Acar, S., and de Chantal, P. L. (2024). Open
#>   Creativity Scoring \[Computer software\]. Denver, CO: University of Denver.
#>   https://openscoring.du.edu. and Organisciak, P., Acar, S., Dumas, D., &
#>   Berthiaume, K. (2023). Beyond semantic distance: Automated scoring of
#>   divergent thinking greatly improves with large language models. *Thinking
#>   Skills and Creativity*, 49, 101356.
#>   <https://doi.org/10.1016/j.tsc.2023.101356>

scored_df
#> # A tibble: 3 × 3
#>   stimulus response                    .originality
#>   <chr>    <chr>                              <dbl>
#> 1 brick    butter for trolls                    3  
#> 2 hammer   make Thor jeallous                   2.7
#> 3 sponge   make it play in a kids show          2.7
```
