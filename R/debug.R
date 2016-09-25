
#' @export

debug <- function(msg, pkg = environmentName(topenv(parent.frame()))) {
  msg <- sub("^!DEBUG\\s+", "", msg)
  full_msg <- paste0(pkg, " ", msg)
  style <- get_package_style(pkg)
  cat(style(full_msg), "\n", sep = "")
}
