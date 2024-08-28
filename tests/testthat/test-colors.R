test_that("color palette is fine", {
  initialize_colors(c("foo", "bar"))
  expect_equal(names(debug_data[["palette"]]), c("foo", "bar"))
  expect_true(all(debug_data[["palette"]] %in% grDevices::colors()))

  initialize_colors(letters)
  expect_equal(names(debug_data[["palette"]]), letters)
  expect_true(all(debug_data[["palette"]] %in% c("silver", grDevices::colors())))
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
