test_that("log levels are instrumented", {

  fs <- list(
    list("fatal",   function() { "!DEBUG-FATAL fatal" }),
    list("error",   function() { "!DEBUG-ERROR error" }),
    list("warning", function() { "!DEBUG-WARNING warning" }),
    list("info",    function() { "!DEBUG-INFO info" }),
    list("debug",   function() { "!DEBUG-DEBUG debug" }),
    list("verbose", function() { "!DEBUG-VERBOSE verbose" })
  )

  for (f in fs) {
    f2 <- instrument(f[[2]])
    expect_output(f2(), f[[1]])
  }
})

test_that("log levels work properly", {

  fs <- list(
    list("fatal",   function() debug("fatal", level = 1)),
    list("error",   function() debug("error", level = 2)),
    list("warning", function() debug("warning", level = 3)),
    list("info",    function() debug("info", level = 4)),
    list("debug",   function() debug("debug", level = 5)),
    list("verbose", function() debug("verbose", level = 6))
  )

  for (pkg_level in 1:6) {
    local_mocked_bindings(get_package_debug_level = function(...) pkg_level)
    for (idx in seq_along(fs)) {
      if (idx <= pkg_level) {
        expect_output(fs[[idx]][[2]](), fs[[idx]][[1]])
      } else {
        expect_silent(fs[[idx]][[2]]())
      }
    }
  }
})
