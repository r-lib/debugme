
#' Debug message
#'
#' Normally this function is *not* called directly, but debug strings
#' are used. See [debugme()].
#'
#' @param msg Message to print, character constant.
#' @param pkg Package name to which the message belongs. Detected
#'   automatically.
#' @return The original message.
#'
#' @export

debug <- function(msg, pkg = environmentName(topenv(parent.frame()))) {
  msg <- sub("^!DEBUG\\s+", "", msg)
  full_msg <- paste0(pkg, " ", get_timestamp(), msg)
  file <- get_output_file()
  style <- if (file == "") get_package_style(pkg) else identity
  cat(style(full_msg), "\n", file = file, sep = "", append = TRUE)
  msg
}

get_output_file <- function() {
  if (is.null(debug_data$output_file)) {
    ""
  } else {
    tryCatch(
      {
        if (isOpen(debug_data$output_fd)) {
          debug_data$output_fd
        } else {
          debug_data$output_fd <- file(debug_data$output_file, open = "a")
        }
      },
      error = function(e) debug_data$output_file
    )
  }
}

get_timestamp <- function() {
  current <- Sys.time()
  res <- if (! is.null(debug_data$timestamp)) {
    diff <- current - debug_data$timestamp
    paste0("+", round(as.numeric(diff) * 1000), "ms ")
  } else {
    ""
  }

  debug_data$timestamp <- current

  res
}
