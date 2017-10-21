
context("debugme")

test_that(".onLoad", {

  val <- NULL

  mockery::stub(.onLoad, "initialize_colors", function(pkgs) val <<- pkgs)
  withr::with_envvar(
    c("DEBUGME" = c("foo,bar")),
    .onLoad()
  )
  expect_identical(val, c("foo", "bar"))
})

test_that("debugme", {

  env <- new.env()
  env$f1 <- function() { "nothing here" }
  env$f2 <- function() { "!DEBUG foobar" }
  env$notme <- "!DEBUG nonono"
  env$.hidden <- function() { "!DEBUG foobar2" }

  expect_silent(debugme(env))

  mockery::stub(debugme, "is_debugged", TRUE)
  debugme(env)

  expect_silent(env$f1())
  expect_output(env$f2(), "debugme foobar \\+[0-9]+ms")
  expect_identical(env$notme, "!DEBUG nonono")
  expect_output(env$.hidden(), "debugme foobar2 \\+[0-9]+ms")
})
