
#' Debug R Packages
#'
#' Specify debug messages as special string constants, and control
#' debugging of packages via environment variables.
#'
#' To add debugging to your package, you need to
#' 1. Import the `debugme` package.
#' 2. Define an `.onLoad` function in your package, that calls `debugme`.
#'    An example:
#'    ```r
#'    .onLoad <- function(libname, pkgname) { debugme::debugme() }
#'    ```
#'
#' By default debugging is off. To turn on debugging, set the `DEBUGME`
#' environment variable to the names of the packages you want to debug.
#' Package names can be separated by commas.
#'
#' Note that `debugme` checks for environment variables when it is starting
#' up. Environment variables set after the package is loaded do not have
#' any effect.
#'
#' Example `debugme` entries:
#' ```
#' "!DEBUG Start Shiny app"
#' ```
#'
#' @section Dynamic debug messsages:
#'
#' It is often desired that the debug messages contain values of R
#' expressions evaluated at runtime. For example, when starting a Shiny
#' app, it is useful to also print out the path to the app. Similarly,
#' when debugging an HTTP response, it is desired to log the HTTP status
#' code.
#'
#' `debugme` allows embedding R code into the debug messages, within
#' backticks. The code will be evaluated at runtime. Here are some
#' examples:
#' ```
#' "!DEBUG Start Shiny app at `path`"
#' "!DEBUG Got HTTP response `httr::status_code(reponse)`"
#' ```
#'
#' Note that parsing the debug strings for code is not very sophisticated
#' currently, and you cannot embed backticks into the code itself.
#'
#' @section Log levels:
#' To organize the log messages into log levels, you can start the
#' `!DEBUG` token with multiple `!` characters. You can then select the
#' desired level of logging via `!` characters before the package name
#' in the `DEBUGME` environment variable. E.g. `DEBUGME=!!mypackage` means
#' that only debug messages with two or less `!` marks will be printed.
#'
#' @section Redirecting the output:
#'
#' If the `DEBUGME_OUTPUT_FILE` environment variable is set to
#' a filename, then the output is written there instead of the standard
#' output stream of the R process.
#'
#' If `DEBUGME_OUTPUT_FILE` is not set, but `DEBUGME_OUTPUT_DIR` is, then
#' a log file is created there, and the name of the file will contain
#' the process id. This is is useful for logging from several parallel R
#' processes.
#'
#' @param env Environment to instument debugging in. Defaults to the
#'   package environment of the calling package.
#' @param pkg Name of the calling package. The default should be fine
#'   for almost all cases.
#'
#' @docType package
#' @name debugme
#' @export

debugme <- function(env = topenv(parent.frame()),
                    pkg = environmentName(env)) {

  if (!is_debugged(pkg)) return()

  should_instrument <- function(x) {
    obj <- get(x, envir = env)
    is.function(obj) || is.environment(obj)
  }

  objects <- ls(env, all.names = TRUE)
  dbg_objects <- Filter(should_instrument, objects)
  Map(
    function(x) assign(x, instrument(get(x, envir = env), pkg), envir = env),
    dbg_objects
  )
}

is_debugged <- function(pkg) {
  pkg %in% names(debug_data$palette)
}

debug_data <- new.env()
debug_data$timestamp <- NULL
debug_data$debug_call_stack <- NULL


.onLoad <- function(libname, pkgname) {
  pkgs <- parse_env_vars()
  pkgnames <- sub("^!+", "", pkgs)
  dbglevels <- get_debug_levels(pkgs)
  initialize_colors(pkgnames)
  initialize_debug_levels(pkgnames, dbglevels)
  initialize_output_file()
}

get_debug_levels <- function(x) {
  m <- regexpr("^(!+)", x)
  len <- attr(m, "match.length")
  ifelse(len < 0, 0, len)
}

parse_env_vars <- function() {
  env <- Sys.getenv("DEBUGME")
  strsplit(env, ",")[[1]]
}

initialize_debug_levels <- function(pkgnames, dbglevels) {
  debug_data$debug_levels <- structure(dbglevels, names = pkgnames)
}

get_package_debug_level <- function(pkg) {
  debug_data$debug_levels[pkg]
}

initialize_output_file <- function() {
  out <- Sys.getenv("DEBUGME_OUTPUT_FILE", "")
  dir <- Sys.getenv("DEBUGME_OUTPUT_DIR", "")
  if (out != "") {
    debug_data$output_file <- out
    debug_data$output_fd <- file(out, open = "a")
  } else if (dir != "") {
    out <- file.path(dir, paste0("debugme-", Sys.getpid(), ".log"))
    debug_data$output_file <- out
    debug_data$output_fd <- file(out, open = "a")
  } else {
    debug_data$output_file <- NULL
  }
}
