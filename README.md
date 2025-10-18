
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RappPKPLT

<!-- badges: start -->

[![R-CMD-check](https://github.com/soutomas/RappPKPLT/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/soutomas/RappPKPLT/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of RappPKPLT is to …

## Citation

``` r
citation("RappPKPLT")
#> To cite package 'RappPKPLT' in publications use:
#> 
#>   Sou T (2025). _RappPKPLT: Shiny Application for a PK-Platelet Model_.
#>   R package version 0.0.0.9000, commit
#>   a494cc205df49093570e6bbe6634901e330e36f3,
#>   <https://github.com/soutomas/RappPKPLT>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {RappPKPLT: Shiny Application for a PK-Platelet Model},
#>     author = {Tomas Sou},
#>     year = {2025},
#>     note = {R package version 0.0.0.9000},
#>     url = {https://github.com/soutomas/RappPKPLT},
#>   }
```

## Installation

You can install the development version of RappPKPLT from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("soutomas/RappPKPLT")
```

## Example

You can run a Shiny application for interaction simulation using a
PK-platelet model:

``` r
library(RappPKPLT)

# To run the Shiny app
app()
```
