


# debugme

> Debug R Packages
<!-- badges: start -->
[![R-CMD-check](https://github.com/r-lib/debugme/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/debugme/actions/workflows/R-CMD-check.yaml)
[![](https://www.r-pkg.org/badges/version/debugme)](https://www.r-pkg.org/pkg/debugme)
[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/debugme)](https://www.r-pkg.org/pkg/debugme)
[![Codecov test coverage](https://codecov.io/gh/r-lib/debugme/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/debugme?branch=main)
<!-- badges: end -->

Specify debug messages as special string constants, and control debugging of
packages via environment variables. This package was largely influenced by
the [`debug` npm package](https://github.com/debug-js/debug).

## Installation and Usage


```r
install.packages("debugme")
```

To use `debugme` in your package, import it, and then add the following
`.onLoad` function to your package:
```r
.onLoad <- function(libname, pkgname) {
  debugme::debugme()
}
```

You can now add debug messages via character literals. No function calls
are necessary. For example:
```r
"!DEBUG Start up phantomjs"
private$start_phantomjs(phantom_debug_level)

"!DEBUG Start up shiny"
private$start_shiny(path)

"!DEBUG create new phantomjs session"
private$web <- session$new(port = private$phantom_port)

"!DEBUG navigate to Shiny app"
private$web$go(private$get_shiny_url())
```

The string literals are simply ignored when debugging is turned off. To
turn on debugging for a package, set the environment variable `DEBUGME` to
the package name you want to debug. E.g. from a `bash` shell:

```sh
export DEBUGME=mypackage
```

Or from within R:

```r
Sys.setenv(DEBUGME = "mypackage")
```

Separate multiple package names with commas:

```sh
export DEBUGME=mypackage,otherpackage
```

The debug messages will be prefixed by the package names, and assuming your
terminal supports color, will be colored differently for each package.

## Example

![](inst/screencast.gif)

## Dynamic code

The `debugme` debug strings may contain R code between backticks.
This code is evaluated at runtime, if debugging is turned on. A single
debug string may contain multiple backticked code chunks:

```r
"!DEBUG x = `x`, y = `y`"
if (x != y) {
...
```

## Motivation

I have always wanted a debugging tool that
* is very simple to use,
* can be controlled via environment variables, without changing anything
  it the packages themselves,
* has zero impact on performance when debugging is off.

`debugme` is such a tool.

### Performance

Function calls are relatively cheap in R, but they still do have an impact.
If you never want to worry about the log messages making your code slower,
you will like `debugme`. `debugme` debug strings have practically no
performance penalty when debugging is off.

Here is a simple comparison to evaluate debugging overhead with a function call, `f1()`,
debugging with debug strings, `f2()`, and no debugging at all.


```r
debug <- function(msg) { }
f1 <- function() {
  for (i in 1:100) {
    debug("foobar")
    # Avoid optimizing away the loop
    i <- i + 1
  }
}
```


```r
f2 <- function() {
  for (i in 1:100) {
    "!DEBUG foobar"
    # Avoid optimizing away the loop
    i <- i + 1
  }
}
```


```r
f3 <- function() {
  for (i in 1:100) {
    # Avoid optimizing away the loop
    i <- i + 1
  }
}
```


```r
microbenchmark::microbenchmark(f1(), f2(), f3())
```

```
#> Warning in microbenchmark::microbenchmark(f1(), f2(), f3()): less accurate
#> nanosecond times to avoid potential integer overflows
```

```
#> Unit: microseconds
#>  expr    min     lq      mean median     uq      max neval cld
#>  f1() 10.332 10.496 103.29499 10.578 10.701 9277.398   100   a
#>  f2()  1.394  1.435   8.29676  1.435  1.435  687.406   100   a
#>  f3()  1.107  1.189   7.86011  1.189  1.189  667.767   100   a
```

## License

MIT © [Gábor Csárdi](https://github.com/gaborcsardi)
