
context("instrument")

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
