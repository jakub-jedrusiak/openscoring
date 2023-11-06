
<!-- README.md is generated from README.Rmd. Please edit that file -->

# openscoring

<!-- badges: start -->
<!-- badges: end -->

## Installation

You can install the development version of openscoring from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jakub-jedrusiak/openscoring")
```

## Example

``` r
library(openscoring)

df <- data.frame(
  stimulus = c("brick", "hammer", "sponge"),
  response = c("butter for trolls", "make Thor jeallous", "make it play in a kids show")
)

oscai(df, stimulus, response)
#> ✔ Remember to cite:
#> 
#> Organisciak, P., & Dumas, D. (2020). Open Creativity Scoring. University of
#>   Denver. https://openscoring.du.edu and Organisciak, P., Acar, S., Dumas, D.,
#>   & Berthiaume, K. (2023). Beyond semantic distance: Automated scoring of
#>   divergent thinking greatly improves with large language models. Thinking
#>   Skills and Creativity, 49, 101356. https://doi.org/10.1016/j.tsc.2023.101356
#>   stimulus                    response .originality
#> 1    brick           butter for trolls          3.8
#> 2   hammer          make Thor jeallous          3.0
#> 3   sponge make it play in a kids show          2.7
```
