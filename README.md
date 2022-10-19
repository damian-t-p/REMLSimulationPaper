
<!-- README.md is generated from README.Rmd. Please edit that file -->

# REMLSimulationPaper

<!-- badges: start -->
<!-- badges: end -->

The goal of REMLSimulationPaper is to …

## Installation

You can install the development version of REMLSimulationPaper from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")

# install package required for simulation and analysis
devtools::install_github("damian-t-p/halfsibdesign")

# install REMLSimulationPaper
devtools::install_github("damian-t-p/REMLSimulationPaper")
```

## Package structure

All simulation results can be found in `.csv` or `.RData` format in the
`/data/` directory. The figures used in the paper are available in the
`/figs/` directory.

To reproduce the simulations and figures, re-build the vignettes by
running

``` r
devtools::build_vignettes(pkg = "REMLSimulationPaper")
```
