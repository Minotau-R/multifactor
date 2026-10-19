# Tools to modify multifactors

Generates a new `multifactor` object by cross-referencing the elements
of a given `multifactor`.

## Usage

``` r
# S3 method for class '`multifactor::multifactor`'
subset(x, .path, .drop.unmatched = FALSE, ...)

# S3 method for class '`multifactor::linkmap`'
subset(x, subset = NULL, ...)

# S3 method for class '`multifactor::multifactor`'
augment(x, ...)
```

## Arguments

- x:

  a `multifactor` or `linkmap`.

- .path:

  Either a `formula` or a `character vector`.

- .drop.unmatched:

  `Boolean`. Whether to drop factor levels that do not appear in the
  data (Default: keep all levels).

- ...:

  Name-value pairs. The name gives the name of the linkmap in the
  output.

- subset:

  Logical expression indicating elements or rows to keep. If `NULL`
  (Default), subsets based on complete coverage if available.

## Value

a `multifactor`.

## Examples

``` r
# Only necessary in example code
require(generics)
#> Loading required package: generics
#> 
#> Attaching package: ‘generics’
#> The following objects are masked from ‘package:base’:
#> 
#>     as.difftime, as.factor, as.ordered, intersect, is.element, setdiff,
#>     setequal, union
# Generate a random multifactor
x <- random_multifactor()

# Use augment to chain together operations like weave and stack, in order.
augment(
  x,
  weave(x, a ~ c),
  stack(x, a + b ~ c + d),
  weave(x, d ~ f)
)
#> A multifactor::multifactor list S7_object,
#>     8 feature types across 8 linkmaps.
#> 
#>          a  b  c  d e  f a.b c.d
#> a2b     10 10  .  . .  .   .   .
#> b2c      . 10 10  . .  .   .   .
#> c2d      .  . 10 10 .  .   .   .
#> d2e      .  .  .  8 9  .   .   .
#> e2f      .  .  .  . 9 10   .   .
#> a2c     10  . 10  . .  .   .   .
#> a.b2c.d  .  .  .  . .  .  20  20
#> d2f      .  .  .  8 . 10   .   .
#> 
#> Values represent unique feature names in that linkmap.
#> 
#> @ levels:
#>  $ a   : 10 Levels: a_001 a_002 ... a_010 
#>  $ b   : 10 Levels: b_001 b_002 ... b_010 
#>  $ c   : 10 Levels: c_001 c_002 ... c_010 
#>  $ d   : 10 Levels: d_001 d_002 ... d_010 
#>  $ e   : 10 Levels: e_001 e_002 ... e_010 
#>  $ f   : 10 Levels: f_001 f_002 ... f_010 
#>  $ a.b : 20 Levels: a_001 a_002 ... b_010 
#>  $ c.d : 20 Levels: c_001 c_002 ... d_010 

# Setting a linkmap to NULL by name deletes it from the multifactor
augment(x, a2b = NULL)
#> A multifactor::multifactor list S7_object,
#>     5 feature types across 4 linkmaps.
#> 
#>      b  c  d e  f
#> b2c 10 10  . .  .
#> c2d  . 10 10 .  .
#> d2e  .  .  8 9  .
#> e2f  .  .  . 9 10
#> 
#> Values represent unique feature names in that linkmap.
#> 
#> @ levels:
#>  $ b : 10 Levels: b_001 b_002 ... b_010 
#>  $ c : 10 Levels: c_001 c_002 ... c_010 
#>  $ d : 10 Levels: d_001 d_002 ... d_010 
#>  $ e : 10 Levels: e_001 e_002 ... e_010 
#>  $ f : 10 Levels: f_001 f_002 ... f_010 
```
