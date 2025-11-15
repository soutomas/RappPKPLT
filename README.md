
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RappPKPLT

<!-- badges: start -->

[![R-CMD-check](https://github.com/soutomas/RappPKPLT/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/soutomas/RappPKPLT/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of RappPKPLT is to provide a Shiny application for interactive
simulation using a PK-platelet-GDF15 model in patients with
haematological malignancies and solid tumours.

## Citation

Sou T (2025). *RappPKPLT: Shiny Application for a PK-Platelet-GDF15
Model*. R package version 0.0.0.9000,
<https://github.com/soutomas/RappPKPLT>.

``` r
citation("RappPKPLT") 
#> To cite package 'RappPKPLT' in publications use:
#> 
#>   Sou T (2025). _RappPKPLT: Shiny Application for a PK-Platelet-GDF15
#>   Model_. R package version 0.0.0.9000,
#>   <https://github.com/soutomas/RappPKPLT>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {RappPKPLT: Shiny Application for a PK-Platelet-GDF15 Model},
#>     author = {Tomas Sou},
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

To run the Shiny application:

``` r
library(RappPKPLT)
app()
```
