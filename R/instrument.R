
instrument <- function(x, pkg) {

  envs <- character()

  recurse <- function(y) { lapply(y, instrument0, pkg) }
  env_recurse <- function(e) {
    nms <- ls(e, all.names = TRUE, sorted = FALSE)
    for (n in nms) e[[n]] <- instrument0(e[[n]], pkg)
    e
  }

  instrument0 <- function(x, pkg) {
    if (is_debug_string(x)) {
      make_debug_call(x)
    } else if (is.atomic(x) || is.name(x)) {
      x
    } else if (is.call(x)) {
      as.call(recurse(x))
    } else if (is.function(x)) {
      formals(x) <- as.list(instrument0(formals(x), pkg))
      body(x) <- instrument0(body(x), pkg)
      x
    } else if (is.pairlist(x)) {
      ## Formal argument lists (when creating functions)
      as.pairlist(recurse(x))
    } else if (is.environment(x) && ! (addr <- env_address(x)) %in% envs) {
      envs <<- c(envs, addr)
      env_recurse(x)
    } else if (is.list(x)) {
      recurse(x)
    } else {
      ## Unknown language type, we just silently ignore
      x
    }
  }

  instrument0(x, pkg)
}

is_debug_string <- function(x) {
  is.character(x) &&
    length(x) == 1 &&
    grepl("^!+DEBUG ", x)
}

make_debug_call <- function(x) {
  x <- handle_dynamic_code(x)
  as.call(list(quote(debugme::debug), x))
}
