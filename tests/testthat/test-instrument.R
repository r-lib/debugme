test_that("negatives", {

  negs <- list(
    function() {},
    function() { "foobar"; print(1:10) },
    function() { "blah !BEBUG"; print(NULL) },
    base::ls,
    base::library
  )

  for (f in negs) {
    f2 <- instrument(f)
    ## Not identical because of the srcrefs
    expect_equal(f, f2)
    expect_identical(formals(f), formals(f2))
    expect_equal(body(f), body(f2))
  }
})

test_that("positives", {

  poss <- list(
    function() { "!DEBUG foobar1" },
    function(x = "!DEBUG foobar1") { x == "really?" },
    function() { for (i in 1:1) { if (TRUE) { "!DEBUG foobar1" } } }
  )

  for (f in poss) {
    f2 <- instrument(f)
    expect_output(f2(), "foobar1")
  }
})

test_that("functions without arguments, #17", {

  f <- function() { "!DEBUG foo"; 'noarg' }
  f2 <- instrument(f)
  expect_output(instrument(f2()), "foo")
})

test_that("unknown objects are not touched", {
  e <- new.env()
  expect_equal(format(e), format(instrument(e)))
})

test_that("debug levels", {
  f <- function() {
    for (i in 1:1) {
      if (TRUE) {
        "!DEBUG foobar1"
      }
      "!!DEBUG foobar2"
    }
    "!!!DEBUG foobar3"
  }
  f2 <- instrument(f)

  expect_output(f2(), "foobar1.*foobar2.*foobar3")
})

test_that("function with attributes", {
  f <- function() {}
  attr(f, "foo") <- "bar"

  f2 <- instrument(f)
  expect_identical(attributes(f), attributes(f2))
})

test_that("circular references", {
  env <- new.env()
  env$l <- list(x = env)
  expect_error(instrument(env), NA)
})
