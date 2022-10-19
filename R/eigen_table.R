#' @export
eigen_table <- function(mat_list, prefix = "lambda", mat_name = "component") {
  mat_list %>%
    map(function(M) eigen(M)$values) %>%
    tibble::as_tibble() %>%
    dplyr::select(-reml_crit) %>%
    t() %>%
    magrittr::set_colnames(., paste(prefix, 1:ncol(.), sep = "")) %>%
    tibble::as_tibble(rownames = mat_name)
}
