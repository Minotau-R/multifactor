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
set.seed(2612)
x <- trade_posts()

# Generate small example feature table '.data'.
n <- nlevels(x)[["fruit"]]
.data <- replicate(10, rbinom(n, rbinom(n, 100, runif(n)), runif(n)))

# Ensure rownames correspond to the first (LHS) variable in the formula.
.data <- as.data.frame(.data, row.names = levels(x)$fruit)

# Define path
.path <- fruit ~ clothing

# Apply arbitrary code to x based on group membership
weave_apply(
  x,
  .path = .path,
  .data = .data,
  .fun = function(x) colSums(x)
)
#> $dress
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  31  62  68  50 150 202  52  81  95 202 
#> 
#> $gloves
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  24  34  36  23  55 137  32  49  64  60 
#> 
#> $hat
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  45  67  99  69 153 267  54 124 106 218 
#> 
#> $scarf
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  45  67  99  69 153 267  54 124 106 218 
#> 
#> $`t-shirt`
#>  V1  V2  V3  V4  V5  V6  V7  V8  V9 V10 
#>  24  34  36  23  55 137  32  49  64  60 
#> 
```
