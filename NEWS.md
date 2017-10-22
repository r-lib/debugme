
# 1.1.0

* Support functions in lists and environments. In particular, this
  fixes debugging R6 methods (#15)

* Support `DEBUGME_OUTPUT_DIR` (#19)

* Support log levels (#12)

* Fix functions without arguments (#17)

* Print the debug stack, optionally (@kforner, #21)

# 1.0.2

* Do not us `testthat::with_mock`, it interferes with the JIT that is
  default in R 3.4.0. Use the `mockery` package instead.

# 1.0.1

* Fix a test case bug.

# 1.0.0

First public release.
