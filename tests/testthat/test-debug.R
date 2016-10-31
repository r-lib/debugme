
context("debug")

test_that("debug prints", {
  expect_output(
    debug("foobar", pkg = "pkg"),
    "pkg foobar"
  )
})

test_that("debug retrieves variables for placeholders", {
  x <- "bar"
  y <- 1

  expect_output(
    debug("x: {{x}}, y: {{y}}", pkg = "pkg"),
    "x: bar, y: 1"
  )
})
