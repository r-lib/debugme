
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
#'    .onLoad <- function(libname, pathname) { debugme::debugme() }
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
#' Example debugme entries:
#' ```
#' "!DEBUG Start Shiny app"
#' ```
#'
#' @docType package
#' @name debugme
NULL

#' @export

debugme <- function(env = topenv(parent.frame()),
                    pkg = environmentName(env)) {

  ## Are we debugging this package?
  if (! pkg %in% names(debug_data$palette)) return()

  objects <- ls(env, all.names = TRUE)
  funcs <- Filter(function(x) is.function(get(x, envir = env)), objects)
  Map(
    function(x) assign(x, instrument(get(x, envir = env)), envir = env),
    funcs
  )
}

debug_data <- new.env()

.onLoad <- function(libname, pathname) {
  pkgs <- parse_env_vars()
  initialize_colors(pkgs)
}

parse_env_vars <- function() {
  env <- Sys.getenv("DEBUGME")
  strsplit(env, ",")[[1]]
}
