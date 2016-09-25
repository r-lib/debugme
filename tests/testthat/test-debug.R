
context("debug")

test_that("debug prints", {
  expect_output(
    debug("foobar", pkg = "pkg"),
    "pkg foobar"
  )
})
