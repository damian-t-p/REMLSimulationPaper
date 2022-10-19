#' @export
get_covs <- function(fit){
  
  resid_sds <- fit$sigma * sqrt((1 + c(0, fit$modelStruct$varStruct)))
  resid_corr <- as.matrix(fit$modelStruct$corStruct)[[1]]
  S1 <- outer(resid_sds, resid_sds) * resid_corr
  
  S2 <- fit$modelStruct$reStruct$dam %>%
      as.matrix()  %>%
      {. * fit$sigma^2}
  rownames(S2) <- NULL
  colnames(S2) <- NULL
  
  S3 <- fit$modelStruct$reStruct$sire %>%
      as.matrix()  %>%
      {. * fit$sigma^2}
  rownames(S3) <- NULL
  colnames(S3) <- NULL
  
  out <- list(
    S1 = S1,
    S2 = S2,
    S3 = S3
  )
  
  ss <- ss_mats(fit$data)
  
  out$reml_crit <- reml_crit(ss$m_ind, out$S1, ss$K, ss$m_dam, out$S2, ss$J, ss$m_sire, out$S3, ss$I)
    
  return(out)
}
