log_error <- function(header = "") {
  function(e) {
    log_print(paste0("ERROR: ", header, "\n", conditionMessage(e)))
  }
}

#' Create a tibble of matrix eigenvalues from a list of matrices
#'
#' @param mat_list A list of symmetric square matrices
#' @param type A variable naming the type group
#' @param iter A variable numbering the iteration
mats_to_eigs <- function(mat_list, type, iter) {
  eig_list <- sapply(
    mat_list,
    \(A) eigen(A, symmetric = TRUE, only.values = TRUE)$values
  ) %>%
    t()

  colnames(eig_list) <- paste0("eig", seq_len(ncol(eig_list)))

  as_tibble(eig_list, rownames = "group") %>%
    mutate(
      type = type,
      iter = iter,
      .before = group
    )
}

#' Randomly permute a vector
#' 
#' When the base R function `sample` is called on a vector with a single numeric element, `n`, it permutes the numbers 1 to `n`.
#' This function instead leaves the single-element vector unchanged
#'
#' @param v A vector to permute
permute <- function(v) {
  v[sample.int(length(v))]
}

#' Permute animals freely (should break Sigma[A] and Sigma[B])
#'
#' @param df A data frame containing measurements to be permuted
#' @param idx_vars A vector of strings of index category variables
#' @param Evar A string indicating name of the animal column in `df`
permute_all <- function(df, idx_vars, Evar) {
  lookup <- df %>%
    select(all_of(idx_vars)) %>%
    mutate(!!sym(Evar) := permute(!!sym(Evar)))

  lookup %>%
    left_join(
      select(df, -all_of(setdiff(idx_vars, Evar))),
      by = Evar
    )
}

# Permute animals within sires (should break Sigma[B])
permute_EA <- function(df, idx_vars, Evar, Avar) {

  lookup <- df %>%
    select(all_of(idx_vars)) %>%
    group_by(!!sym(Avar)) %>%
    mutate(!!sym(Evar) := permute(!!sym(Evar))) %>%
    ungroup()

  lookup %>%
    left_join(
      select(df, -all_of(setdiff(idx_vars, Evar))),
      by = Evar
    )
  
}

# Permute dams within sires (should break Sigma[A])
permute_BA <- function(df, idx_vars, Bvar, Avar) {

  lookup <- df %>%
    select(all_of(c(Bvar, Avar))) %>%
    distinct() %>%
    mutate(!!sym(Bvar) := permute(!!sym(Bvar)))

  lookup %>%
    left_join(
      select(df, -all_of(Avar)),
      by = Bvar
    )
  
}
