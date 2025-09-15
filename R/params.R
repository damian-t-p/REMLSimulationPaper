# Script parameters

params <- list(

  # CHC melongaster data
  CHC  = list(
    err_tol       = 1e-3,
    n_boot_iter   = 15,
    n_perm_iter   = 15,
    method        = "REML",
    data_source   = "data/chc_melanogaster.csv",
    output_path   = "output/chc_melanogaster_eigs.csv"
  ),

  # 100 traits of Indica rice
  indica_100 = list(
    err_tol      = 1e-3,
    n_boot_iter  = 15,
    n_perm_iter  = 15,
    method       = "REML",
    data_source  = "data/2016DS_Dry_Indiv_IndAus_Normalized_Standardized_100.csv",
    output_path  = "output/indica_100.csv"
  ),

  # 1000 traits of Indica rice
  indica_1000 = list(
    err_tol      = 1e-3,
    n_boot_iter  = 10,
    n_perm_iter  = 10,
    method       = "REML",
    data_source  = "data/2016DS_Dry_Indiv_IndAus_Normalized_Standardized_1000.csv",
    output_path  = "output/indica_1000.csv"
  )
)
