
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
  file <- get_output_file()

  time_stamp_mode <- if (file == "") "diff" else "stamp"
  full_msg <- paste0(pkg, " ", get_timestamp(time_stamp_mode), msg)

  style <- if (file == "") get_package_style(pkg) else identity
  cat(style(full_msg), "\n", file = file, sep = "", append = TRUE)

  msg
}

get_output_file <- function() {
  if (is.null(debug_data$output_file)) {
    ""
  } else {
    debug_data$output_fd
  }
}

get_timestamp <- function(mode = c("diff", "stamp")) {
  if (mode == "diff") {
    get_timestamp_diff()
  } else {
    get_timestamp_stamp()
  }
}

get_timestamp_diff <- function() {
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

get_timestamp_stamp <- function() {
  paste0(format_date(Sys.time()), " ")
}

format_date <- function(date) {
  format(as.POSIXlt(date, tz = "UTC"), "%Y-%m-%dT%H:%M:%S.%OS3+00:00")
}
