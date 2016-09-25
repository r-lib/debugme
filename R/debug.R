
#' Debug message
#'
#' Normally this function is *not* called directly, but debug strings
#' are used. See [debugme()].
#'
#' @param msg Message to print, character constant.
#' @param pkg Package name to which the message belongs. Detected
#'   automatically.
#'
#' @export

debug <- function(msg, pkg = environmentName(topenv(parent.frame()))) {
  msg <- sub("^!DEBUG\\s+", "", msg)
  full_msg <- paste0(pkg, " ", msg)
  style <- get_package_style(pkg)
  cat(style(full_msg), "\n", sep = "")
}
