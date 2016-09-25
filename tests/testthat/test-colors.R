
context("colors")

test_that("color palette is fine", {

  val <- NULL

  with_mock(
    `base::assign` = function(x, value, envir, ...) val <<- value,
    initialize_colors(c("foo", "bar"))
  )
  expect_equal(names(val), c("foo", "bar"))
  expect_true(all(val %in% grDevices::colors()))

  with_mock(
    `base::assign` = function(x, value, envir, ...) val <<- value,
    initialize_colors(letters)
  )
  expect_equal(names(val), letters)
  expect_true(all(val %in% c("silver", grDevices::colors())))
})

## Quite an artificial test case...

test_that("get a package style", {
  ret <- with_mock(
    `base::match` = function(...) 1L,
    `debugme::make_style` = function(x) { substitute(x) },
    get_package_style("pkg")
  )

  expect_equal(ret, quote(debug_data$palette[pkg]))
})
