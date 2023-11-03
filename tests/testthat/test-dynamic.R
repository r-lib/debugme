test_that("handle_dynamic_code", {

  expect_equal(
    handle_dynamic_code("blah"),
    "blah"
  )

  expect_equal(
    handle_dynamic_code("blah `x` borg"),
    substitute(paste0("blah ", x, " borg"))
  )
})
