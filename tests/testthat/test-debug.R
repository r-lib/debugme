test_that("debug indent", {
  f1 <- function() {
      debug("f1")
      f2()
  }

  f2 <- function() {
      debug("f2.1")
      f3()
      debug("f2.2")
  }
  f3 <- function() {
      debug("f3")
  }

  out <- capture_output(eval({ debug("f0.1"); f1(); f2(); debug("f0.2")}))

  expect_match(out, 'debugme f0.1', fixed = TRUE)
  expect_match(out, 'debugme +-f1', fixed = TRUE)
  expect_match(out, 'debugme   +-f2.1', fixed = TRUE)
  expect_match(out, 'debugme     +-f3', fixed = TRUE)
  expect_match(out, 'debugme    -f2.2', fixed = TRUE)
  expect_match(out, 'debugme +-f2.1', fixed = TRUE)
  expect_match(out, 'debugme  -f2.2', fixed = TRUE)
  expect_match(out, 'debugme f0.2', fixed = TRUE)

  out <- withr::with_envvar(
    c(DEBUGME_SHOW_STACK = "no"),
    capture_output(eval({ debug("f0.1"); f1(); f2(); debug("f0.2")}))
  )

  expect_match(out, 'debugme f0.1', fixed = TRUE)
  expect_match(out, 'debugme f1', fixed = TRUE)
  expect_match(out, 'debugme f2.1', fixed = TRUE)
  expect_match(out, 'debugme f3', fixed = TRUE)
  expect_match(out, 'debugme f2.2', fixed = TRUE)
  expect_match(out, 'debugme f2.1', fixed = TRUE)
  expect_match(out, 'debugme f2.2', fixed = TRUE)
  expect_match(out, 'debugme f0.2', fixed = TRUE)
})

test_that("debug levels", {

  mockery::stub(debug, "get_package_debug_level", 1)
  env <- new.env()
  env$f1 <- function() debug("foobar", level = 1)
  env$f2 <- function() debug("baz", level = 2)
  expect_output(env$f1(), "foobar")
  expect_silent(env$f2())
})

test_that("debug prints", {
  expect_output(
    debug("foobar", pkg = "pkg"),
    "pkg foobar"
  )
})

test_that("format_date", {
  d <- "2016-11-01 02:33:54"
  expect_identical(
    format_date(d),
    "2016-11-01T02:33:54.54.000+00:00"
  )
})

test_that("get_timestamp_stamp", {

  mytime <- structure(1477967634, class = c("POSIXct", "POSIXt"),
                      tzone = "UTC")
  mockery::stub(get_timestamp_stamp, "Sys.time", mytime)
  expect_equal(
    get_timestamp_stamp(),
    "2016-11-01T02:33:54.54.000+00:00 "
  )
})

test_that("debugging to a file", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)

  on.exit(initialize_output_file(), add = TRUE)
  on.exit(try(close(debug_data$output_fd), silent = TRUE), add = TRUE)

  withr::with_envvar(c(DEBUGME_OUTPUT_FILE = tmp), {
    initialize_output_file()
  })
  debug("hello world!", "foobar")
  debug("hello again!", "foo")

  log <- readLines(tmp)
  expect_match(log[1], "^foobar hello world!")
  expect_match(log[2], "^foo hello again!")
})

test_that("debugging to a directory", {
  tmp <- tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  on.exit(initialize_output_file(), add = TRUE)
  on.exit(try(close(debug_data$output_fd), silent = TRUE), add = TRUE)

  withr::with_envvar(c(DEBUGME_OUTPUT_DIR = tmp), {
    initialize_output_file()
  })
  debug("hello world!", "foobar")
  debug("hello again!", "foo")

  log <- readLines(file.path(tmp, paste0("debugme-", Sys.getpid(), ".log")))
  expect_match(log[1], "^foobar hello world!")
  expect_match(log[2], "^foo hello again!")
})
