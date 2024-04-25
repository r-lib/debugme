# debugme 1.2.0

* debugme now does not instrumented code multiple times, this
  could happen if environments were referenced from multiple
  places (#15).

* debugme now correctly instruments functions with attributes,
  the attributes are kept now. Some packages, e.g. `assertthat` create
  such functions.

* debugme now supports debug levels. Relatedly, `debugme()` has a
  `level` argument now (#49, @krlmlr).

* debugme now correctly instruments functions with `NULL` body
  and functions with no arguments.

* Nested calls are printed better now, with indentation (#44, @krlmlr).

* `debugme()` now re-reads the `DEBUGME` environment variable
  (#45, @krlmlr).

* New `DEBUGME_SHOW_TIMESTAMP` environment variable to hide timestamp
  output for reproducibility (#49, @krlmlr).

* debugme now does not change the random seed (#50).

# debugme 1.1.0

* Support functions in lists and environments. In particular, this
  fixes debugging R6 methods (#15)

* Support `DEBUGME_OUTPUT_DIR` (#19)

* Support log levels (#12)

* Fix functions without arguments (#17)

* Print the debug stack, optionally (@kforner, #21)

# debugme 1.0.2

* Do not us `testthat::with_mock`, it interferes with the JIT that is
  default in R 3.4.0. Use the `mockery` package instead.

# debugme 1.0.1

* Fix a test case bug.

# debugme 1.0.0

First public release.
