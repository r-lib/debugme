
#' Handle the dynamic code in a debug string
#'
#' Substrings within backticks will be interpreted as code.
#'
#' @param str Debug string.
#' @return A language expression or a string, depending on whether the
#'   string has dynamic code.
#' @keywords internal

handle_dynamic_code <- function(str) {
  splits <- strsplit(str, "`")[[1]]
  if (length(splits) == 1) return(str)

  ## Odd ones are strings, even ones are code
  splits <- as.list(splits)
  for (i in seq_along(splits)) {
    if (! i %% 2) {
      splits[[i]] <- eval(parse(text = paste0("quote(", splits[[i]], ")")))
    }
  }

  as.call(c(list(quote(paste0)), splits))
}
