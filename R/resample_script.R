library(tidyverse)
library(logr)

################
#
# Setup
#
###############


set.seed(123457)
#source("./params.R")
#source("./functions.R")

################
#
# CHC resampling
#
################

chc_log <- log_open("./chc.log")

tryCatch({
  df <- read_csv(params$CHC$data_source)

  df_sub <-df %>%
    select(-c(block, success)) %>%
    drop_na()

  data <- halfsibdesign::halfsibdata(
    df_sub,
    sire_name = sire,
    dam_name  = dam,
    ind_name  = animal,
    df_format = "wide"
  )

  # reference REML fit
  ref_mats <- halfsibdesign::EM_fit(
    data,
    method  = params$CHC$method,
    err.tol = params$CHC$err_tol)

  write_csv(
    mats_to_eigs(
      mat_list = ref_mats,
      type     = "reference",
      iter     = 0L
    ),
    file = params$CHC$output_path
  )
}, error = log_error("(Fitting to initial CHC data)")
)

# Parametric bootstrap

for (b in seq_len(params$CHC$n_boot_iter)) {
  tryCatch({
    sim_df <- halfsibdesign::rhalfsib(
      mu = rep(0, data$dims$q),
      A  = ref_mats$sire,
      I  = data$dims$I,
      B  = ref_mats$dam,
      J  = data$dims$J,
      E  = ref_mats$animal,
      K  = data$dims$K
    ) %>%
      rename(animal = individual)

    sim_data <- halfsibdesign::halfsibdata(
      sim_df,
      sire_name  = sire,
      dam_name   = dam,
      ind_name   = animal,
      df_format  = "long"
    )

    boot_mats <- halfsibdesign::EM_fit(
      sim_data,
      method  = params$CHC$method,
      err.tol = params$CHC$err_tol
    )


    write_csv(
      mats_to_eigs(
        mat_list = boot_mats,
        type     = "parametric_bootstrap",
        iter     = b
      ),
      file   = params$CHC$output_path,
      append = TRUE
    )

  }, error = log_error(paste0("(CHC parametric bootstrap replicate #", b, ")")))
}


# Permutation tests

perm_fns <- list(
  all          = \(df) permute_all(df, c("sire", "dam", "animal"), "animal"),
  animal_sire  = \(df) permute_EA(df, c("sire", "dam", "animal"), "animal", "sire"),
  dam_sire     = \(df) permute_BA(df, c("sire", "dam", "animal"), "dam", "sire")
)

for (i in seq_len(params$CHC$n_perm_iter)) {
  for (perm_type in names(perm_fns)) {
    tryCatch({
      
      df_perm <- perm_fns[[perm_type]](df_sub)
      
      data_perm <- halfsibdesign::halfsibdata(
        df_perm,
        sire_name = sire,
        dam_name  = dam,
        ind_name  = animal,
        df_format = "wide"
      )

      perm_mats <- halfsibdesign::EM_fit(
        data_perm,
        method  = params$CHC$method,
        err.tol = params$CHC$err_tol
      )

      write_csv(
        mats_to_eigs(
          mat_list = perm_mats,
          type     = paste0("permutation-", perm_type),
          iter     = i
        ),
        file   = params$CHC$output_path,
        append = TRUE
      )
      
    }, error = log_error(paste0("(CHC permutation ", perm_type, " #", i, ")")))
  }
  
  
}

log_close()


################
#
# Indica resampling
#
################

indica_names <- c("indica_100", "indica_1000")

for (indica_name in indica_names) {

  tryCatch({
    chc_log <- log_open(paste0("./", indica_name, ".log"))
    
    df_rice <- read_csv(
      params[[indica_name]]$data_source,
      col_select = -1) %>%
      pivot_longer(
        cols      = !geneID,
        names_to  = c("individual", "replicate"),
        names_sep = "_rep") %>%
      mutate(replicate = paste(individual, replicate, sep = "-")) %>%
      pivot_wider(id_cols     = c(individual, replicate),
                  names_from  = geneID,
                  values_from = value)

    rice_data <- covcomponents::nesteddata(
      df_rice,
      factors = c("replicate", "individual")
    )

    ref_mats <- covcomponents:::fit_covs.nesteddata(
      rice_data,
      method   = params[[indica_name]]$method
    )

    write_csv(
      mats_to_eigs(
        mat_list = ref_mats,
        type     = "reference",
        iter     = 0L
      ),
      file = params[[indica_name]]$output_path
    )
  }, error = log_error(paste0("(Fitting to initial ", indica_name, " data)")))

  # Parametric bootstrap
  
  for (b in seq_len(params[[indica_name]]$n_boot_iter)) {
    tryCatch({
      sim_df <- halfsibdesign::rfullsib(
        mu = rep(0, nrow(rice_data$sos_matrix)),
        A  = ref_mats$individual,
        I  = attr(rice_data, "n_levels")[["individual"]],
        E  = ref_mats$replicate,
        J  = attr(rice_data, "n_levels")[["replicate"]]
      ) %>%
        rename(
          individual = sire,
          replicate  = individual
        ) %>%
        pivot_wider(id_cols     = c(individual, replicate),
                    names_from  = trait,
                    values_from = value)
 
      sim_data <- covcomponents::nesteddata(
        sim_df,
        factors = c("replicate", "individual")
      )

      boot_mats <- covcomponents:::fit_covs.nesteddata(
        sim_data,
        method   = params[[indica_name]]$method
      )

      write_csv(
        mats_to_eigs(
          mat_list = boot_mats,
          type     = "parametric_bootstrap",
          iter     = b
        ),
        file   = params[[indica_name]]$output_path,
        append = TRUE
      )

    }, error = log_error(paste0("(", indica_name, "parametric bootstrap replicate #", b, ")")))
  }


  # permutations
  
  for (i in seq_len(params[[indica_name]]$n_perm_iter)) {
    tryCatch({
      
      df_perm <- permute_all(df_rice, c("individual", "replicate"), "replicate")

      data_perm <- covcomponents::nesteddata(
        df_perm,
        factors = c("replicate", "individual")
      )

      perm_mats <- covcomponents:::fit_covs.nesteddata(
        data_perm,
        method   = params[[indica_name]]$method
      )
      
      write_csv(
        mats_to_eigs(
          mat_list = perm_mats,
          type     = "permutation-all",
          iter     = i
        ),
        file   = params[[indica_name]]$output_path,
        append = TRUE
      )
      
    }, error = log_error(paste0("(", indica_name, "permutation replicate #", b, ")")))
    

  }
  
  log_close()
}

