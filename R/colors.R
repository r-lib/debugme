
#' @importFrom grDevices colors

initialize_colors <- function(debug_pkgs) {
  local_seed()

  cols <- c("green", "blue", "magenta", "cyan", "white", "yellow", "red",
            "silver")

  palette <- structure(
    c(
      cols,
      sample(colors(), max(length(debug_pkgs) - length(cols), 0))
    )[seq_along(debug_pkgs)],
    names = debug_pkgs
  )

  assign("palette", palette, envir = debug_data)
}

#' @importFrom crayon make_style

get_package_style <- function(pkg) {
  if (is_debugged(pkg)) {
    make_style(debug_data$palette[pkg])
  } else {
    identity
  }
}

local_seed <- function(.local_envir = parent.frame()) {
  old_seed <- get_seed()
  set_seed(debug_data$seed)
  defer({
    debug_data$seed <- get_seed()
    set_seed(old_seed)
  }, envir = .local_envir)
}

has_seed <- function() {
  exists(".Random.seed", globalenv(), mode = "integer", inherits = FALSE)
}

get_seed <- function() {
  if (has_seed()) {
    get(".Random.seed", globalenv(), mode = "integer", inherits = FALSE)
  }
}

set_seed <- function(seed) {
  if (is.null(seed)) {
    if (exists(
      ".Random.seed",
      globalenv(),
      mode = "integer",
      inherits = FALSE)) {
      rm(".Random.seed", envir = globalenv())
    }

  } else {
    assign(".Random.seed", seed, globalenv())
  }
}

f <- function() {
  local_seed()
  sample(1:5)
}
