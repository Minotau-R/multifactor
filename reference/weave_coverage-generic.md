# Weave a path through an object and return coverage statistics

`weave_coverage()` is an S7 generic that finds a path through a
relational object and return coverage statistics.

## Usage

``` r
weave_coverage(x, .path, ...)
```

## Arguments

- x:

  input object

- .path:

  either a `formula` or a `character vector` of length 2 with the names
  of the desired combination of feature types.

- ...:

  additional arguments

## Value

a `linkmap` or `matrix`.

## Examples

``` r
# Available methods:
weave_coverage
#> <S7_generic> weave(x, .path, ...) with 1 methods:
#> 1: method(weave, multifactor::multifactor)
```
