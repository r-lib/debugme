test_that(".onLoad", {
  withr::with_envvar(
    c("DEBUGME" = c("foo,bar")),
    refresh_pkg_info()
  )
  expect_identical(names(debug_data$palette), c("foo", "bar"))
})

test_that("debugme", {

  env <- new.env()
  env$f1 <- function() { "nothing here" }
  env$f2 <- function() { "!DEBUG foobar" }
  env$notme <- "!DEBUG nonono"
  env$.hidden <- function() { "!DEBUG foobar2" }

  withr::local_envvar(DEBUGME = "debugme")
  refresh_pkg_info()
  debugme(env, pkg = "debugme")

  expect_silent(env$f1())
  expect_output(env$f2(), "debugme foobar ")
  expect_identical(env$notme, "!DEBUG nonono")
  expect_output(env$.hidden(), "debugme foobar2 \\+[0-9]+ms")
})

test_that("instrument environments", {

  env <- new.env()
  env$env <- new.env()
  env$env$fun <- function() { "!DEBUG coocoo" }

  withr::local_envvar(DEBUGME = "debugme")
  refresh_pkg_info()
  debugme(env, pkg = "debugme")

  expect_output(env$env$fun(), "coocoo")
})

test_that("instrument R6 classes", {
  env <- new.env()
  env$class <- R6::R6Class(
    "foobar",
    public = list(
      initialize = function(name) {
        "!DEBUG creating `name`"
        private$name <- name
      },
      hello = function() {
        "!DEBUG hello `private$name`"
        paste("Hello", private$name)
      }
    ),
    private = list(
      name = NULL
    )
  )

  withr::local_envvar(DEBUGME = "debugme")
  refresh_pkg_info()
  debugme(env, pkg = "debugme")

  expect_output(x <- env$class$new("mrx"), "debugme.*creating mrx")
  expect_output(x$hello(), "debugme.*hello mrx")
})

test_that("parse_package_debug_levels", {
  expect_equal(
    parse_package_debug_levels(
      c("!!foobar", "!!!bar", "bar-INFO", "bar-WARNING")),
    c(2,3,4,3)
  )
})
