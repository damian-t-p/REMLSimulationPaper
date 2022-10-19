
<!-- README.md is generated from README.Rmd. Please edit that file -->

# REMLSimulationPaper

<!-- badges: start -->
<!-- badges: end -->

This is a package which reproduces the simulations and figures used in
the REML simulation paper.

## Installation

You can install REMLSimulationPaper from [GitHub](https://github.com/)
by running the following in an R console:

``` r
# install.packages("devtools")

# install package required for simulation and analysis
devtools::install_github("damian-t-p/halfsibdesign")

# install REMLSimulationPaper
devtools::install_github("damian-t-p/REMLSimulationPaper")
```

## Package structure and reproduction

All simulation results can be found in `.csv` or `.RData` format in the
`/data/` directory. The figures used in the paper are available in the
`/figs/` directory.

To reproduce the simulations and figures, re-build the vignettes by
running

``` r
devtools::build_vignettes(pkg = "REMLSimulationPaper")
```

The compiled vignettes can be found in the `/docs/` directory.
