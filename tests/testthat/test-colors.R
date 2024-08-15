test_that("color palette is fine", {

  val <- NULL

  local_mocked_bindings(
    assign_debug = function(x, value) {
      val <<- value
    }
  )
  initialize_colors(c("foo", "bar"))
  expect_equal(names(val), c("foo", "bar"))
  expect_true(all(val %in% grDevices::colors()))

  initialize_colors(letters)
  expect_equal(names(val), letters)
  expect_true(all(val %in% c("silver", grDevices::colors())))
})

## Quite an artificial test case...

test_that("get a package style", {
  local_mocked_bindings(
    is_debugged = function(...) TRUE,
    make_style = function(x) substitute(x)
  )
  ret <- get_package_style("pkg")
  expect_equal(ret, quote(debug_data$palette[pkg]))
})
