
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
  msg <- nprintf(sub("^!DEBUG\\s+", "", msg), parent.frame())
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

# Failsafe templating. Retrieves variables from 'envir'.
#
# example:
# envir = list2env(list(x = 1, y = 2, z = 3))
# nprintf(fmt = "foo: {{x}}; bar: {{y}}; foobar: {{z}}; notfound: {{xxx}}", envir)
#
# nprintf("iris: {{class(iris)}} [{{nrow(iris)}}x{{ncol(iris)}}]")
nprintf = function(fmt, envir = parent.frame()) {
  placeholders <- gregexpr("\\{\\{[^}]+\\}\\}", fmt)
  matches <- regmatches(fmt, placeholders)[[1L]]
  if (length(matches) == 0L)
    return(fmt)
  matches = sub("^\\{\\{([^}]+)\\}\\}$", "\\1", matches)
  values <- lapply(matches, function(expr) {
    tryCatch(toString(eval(parse(text = expr), envir = envir)), error = function(e) sprintf("[%s]", expr))
  })

  # replace placeholders in fmt with evaluated expressions
  regmatches(fmt, placeholders) <- list(values)
  return(fmt)
}
