# Statistically estimate enrichment using relational data

`test_enrich()` is an S7 generic that computes statistical enrichment
through a relational object.

## Usage

``` r
test_enrich(x, ..., .data = NULL)
```

## Arguments

- x:

  input object

- ...:

  additional arguments

- .data:

  an R object, such as tabular data.

## Value

a linkmap.

## Examples

``` r
# Available methods:
test_enrich
#> <S7_generic> test_enrich(x, ..., .data = NULL) with 2 methods:
#> 1: method(test_enrich, multifactor::linkmap)
#> 2: method(test_enrich, multifactor::multifactor)
```
