# Index a table by a multifactor and apply arbitrary code to it

`weave_apply` can run arbitrary code specified by `FUN` across any
number of row-based subsets of table `.data`. Mimics lapply.

## Arguments

- .x:

  a `multifactor` object.

- .path:

  either a `formula` or a \`character vector“ of length 2 with the names
  of the desired combination of feature types.

- .data:

  `A table`. A `data.frame`, `matrix`, other object with rows and
  columns.

- .fun:

  A function, passed to lapply.

- ...:

  Additional arguments passed to lapply call.

- .index:

  `Character scalar` Where in `.x` can the target feature names be
  found. (Default: "row.names")

## Value

a `Named list` of desired output.

## See also

[`weave()`](https://minotau-r.github.io/multifactor/reference/weave-generic.md)
[`lapply()`](https://rdrr.io/r/base/lapply.html)
[`linkmap()`](https://minotau-r.github.io/multifactor/reference/linkmap-class.md)
[`multifactor()`](https://minotau-r.github.io/multifactor/reference/multifactor-class.md)

## Examples

``` r

# Prepare data
x <- trade_posts()

# Generate small example feature table 'df'.
n <- nlevels(x)[["clothing"]]
df <- replicate(10, rbinom(n, rbinom(n, 100, runif(n)), runif(n)))

#' # Ensure rownames correspond to the second (RHS) variable in the formula.
df <- as.data.frame(df, row.names = levels(x)$clothing)

# Apply arbitrary code to x based on group membership
weave_apply(
  x,
  .path = fruit ~ clothing,
  .data = df,
  .fun = function(x) colSums(x)
)
#> $apples
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  13  28  69   5   6  13   0   0   7  29 
#> 
#> $pears
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  23  10  32  12  14  17  15  94  56   7 
#> 
#> $cherries
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>   1  17   4   6  55  13  22   7   8  10 
#> 
#> $oranges
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  24  27  36  18  69  30  37 101  64  17 
#> 
#> $melons
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  24  27  36  18  69  30  37 101  64  17 
#> 
#> $grapes
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  14  45  73  11  61  26  22   7  15  39 
#> 
```
