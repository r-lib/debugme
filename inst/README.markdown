


# debugme

> Debug R Packages

[![Linux Build Status](https://travis-ci.org/r-lib/debugme.svg?branch=master)](https://travis-ci.org/r-lib/debugme)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/r-lib/debugme?svg=true)](https://ci.appveyor.com/project/gaborcsardi/debugme)
[![](http://www.r-pkg.org/badges/version/debugme)](http://www.r-pkg.org/pkg/debugme)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/debugme)](http://www.r-pkg.org/pkg/debugme)
[![Coverage Status](https://img.shields.io/codecov/c/github/r-lib/debugme/master.svg)](https://codecov.io/github/r-lib/debugme?branch=master)

Specify debug messages as special string constants, and control debugging of
packages via environment variables. This package was largely influenced by
the [`debug` npm package](https://github.com/visionmedia/debug).

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
#> Unit: microseconds
#>  expr    min      lq      mean median      uq       max neval cld
#>  f1() 19.585 20.8030 189.88149 21.718 23.5735 16721.969   100   a
#>  f2()  4.988  5.8665  26.00780  7.314  9.5685  1777.398   100   a
#>  f3()  4.513  5.4030  25.57436  6.354  8.3195  1793.295   100   a
```

## License

MIT © [Gábor Csárdi](https://github.com/gaborcsardi)
