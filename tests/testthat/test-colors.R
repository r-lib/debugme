
context("colors")

test_that("color palette is fine", {

  val <- NULL

  mockery::stub(initialize_colors, "assign",
                function(x, value, envir, ...) val <<- value)
  initialize_colors(c("foo", "bar"))
  expect_equal(names(val), c("foo", "bar"))
  expect_true(all(val %in% grDevices::colors()))

  initialize_colors(letters)
  expect_equal(names(val), letters)
  expect_true(all(val %in% c("silver", grDevices::colors())))
})

## Quite an artificial test case...

test_that("get a package style", {

  mockery::stub(get_package_style, "is_debugged", function(...) TRUE)
  mockery::stub(get_package_style, "make_style", function(x) substitute(x))
  ret <- get_package_style("pkg")
  expect_equal(ret, quote(debug_data$palette[pkg]))
})
