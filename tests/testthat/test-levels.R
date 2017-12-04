
context("log levels")

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
    list("fatal",   function() debug("!DEBUG-FATAL fatal")),
    list("error",   function() debug("!DEBUG-ERROR error")),
    list("warning", function() debug("!DEBUG-WARNING warning")),
    list("info",    function() debug("!DEBUG-INFO info")),
    list("debug",   function() debug("!DEBUG-DEBUG debug")),
    list("verbose", function() debug("!DEBUG-VERBOSE verbose"))
  )

  for (pkg_level in 1:6) {
    mockery::stub(debug, "get_package_debug_level", pkg_level)
    for (idx in seq_along(fs)) {
      if (idx <= pkg_level) {
        expect_output(fs[[idx]][[2]](), fs[[idx]][[1]])
      } else {
        expect_silent(fs[[idx]][[2]]())
      }
    }
  }
})
