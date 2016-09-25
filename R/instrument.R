
instrument <- function(x) {

  recurse <- function(y) { lapply(y, instrument) }

  if (is_debug_string(x)) {
    make_debug_call(x)
  } else if (is.atomic(x) || is.name(x)) {
    x
  } else if (is.call(x)) {
    as.call(recurse(x))
  } else if (is.function(x)) {
    formals(x) <- instrument(formals(x))
    body(x) <- instrument(body(x))
    x
  } else if (is.pairlist(x)) {
    # Formal argument lists (when creating functions)
    as.pairlist(recurse(x))
  } else {
    ## Unknown language type, we just silently ignore
  }
}

is_debug_string <- function(x) {
  is.character(x) &&
    length(x) == 1 &&
    identical(substring(x, 1, 7), "!DEBUG ")
}

make_debug_call <- function(x) {
  as.call(list(quote(debugme::debug), x))
}
