
#' Debug message
#'
#' Normally this function is *not* called directly, but debug strings
#' are used. See [debugme()].
#'
#' @param msg Message to print, character constant.
#' @param pkg Package name to which the message belongs. Detected
#'   automatically.
#' @param level The maximum debug level to show this message at.
#' @return Invisibly, the message if it is shown, otherwise `NULL`.
#'
#' @export

debug <- function(msg, pkg = environmentName(topenv(parent.frame())), level = 2) {

  pkg_level <- get_package_debug_level(pkg)
  if (!is.na(pkg_level) && pkg_level > 0 && pkg_level < level) {
    return(invisible(NULL))
  }

  force(msg)
  file <- get_output_file()

  time_stamp_mode <- if (file == "") "diff" else "stamp"

  indent <- " "

  if (tolower(Sys.getenv("DEBUGME_SHOW_STACK", "yes")) != "no") {
    level <- update_debug_call_stack_and_compute_level()
    continuation <- isTRUE(attr(level, "continuation"))
    if (level > 0) {
      indent <- paste0(
        c(" " , rep(" ", (level - 1) * 2), if (continuation) " -" else "+-"),
        collapse = "")
    }
  }

  full_msg <- paste0(pkg, indent,  msg, " ",
                     get_timestamp(time_stamp_mode))

  style <- if (file == "") get_package_style(pkg) else identity
  cat(style(full_msg), "\n", file = file, sep = "", append = TRUE)

  invisible(msg)
}

get_log_levels <- function() {
  c(FATAL   = 1,
    ERROR   = 2,
    WARNING = 3,
    INFO    = 4,
    DEBUG   = 5,
    VERBOSE = 6
    )
}

get_msg_debug_levels <- function(x) {
  m <- re_match(x, "^!DEBUG-(?<level>[^\\s]+)\\s+")
  if (! is.na(m$.match)) {
    wh <- match(m$level, names(get_log_levels()))
    if (is.na(wh)) {
      warning("Unknown debug level: `", m$level, "`")
      0
    } else {
      wh
    }
  } else {
    m <- re_match(x, "^(!+)DEBUG\\s+")
    if (is.na(m[1,1])) 0 else nchar(m[1,1])
  }
}

env_address <- function(env) {
  sub("<environment: (.*)>", "\\1", format(env))
}

update_debug_call_stack_and_compute_level <- function() {
  # -2L for update_debug_call_stack_and_compute_level() and debug() calls
  nframe <- sys.nframe() - 2L
  level <- 0L
  frames <- sys.frames()

  for (i in seq_along(debug_data$debug_call_stack)) {
    call <- debug_data$debug_call_stack[[i]]
    if (call$nframe <= nframe &&
      call$id == env_address(frames[[call$nframe]])) {

      if (call$nframe == nframe) {
        return(structure(call$level, continuation = TRUE))
      }

      level <- call$level + 1L
      break
    }
  }

  call <- list(
    nframe = nframe,
    id = env_address(frames[[nframe]]),
    level = level)

  if (level > 0) {                      # found
    debug_data$debug_call_stack <-
      c(list(call), debug_data$debug_call_stack[seq(i, length(debug_data$debug_call_stack))])

  } else {                              # new stack
    debug_data$debug_call_stack <- list(call)
  }

  structure(level, continuation = FALSE)
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
