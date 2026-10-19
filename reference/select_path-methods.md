# Define a path through a multifactor object.

Define a path through a multifactor object.

## Arguments

- x:

  input object

- .path:

  either a `formula` or a `character vector` of length 2 with the names
  of the desired combination of feature types.

## Value

a `factor_path` object.

## Examples

``` r
# Generate pair of random linkage input
a2b <- data.frame(
  a = sample(letters[seq(3)], 10, replace = TRUE),
  b = sample(LETTERS[seq(3)], 10, replace = TRUE)
)
a2c <- data.frame(
  a = sample(letters[seq(3)], 10, replace = TRUE),
  c = sample(c("x", "y", "z"), 10, replace = TRUE)
)

# Create multifactor
x <- multifactor(list(a2b, a2c))

# Inspect a path between data types
select_path(x, b ~ c)
#> A multifactor::path_frame S7_object.
#>   A path from `b` to `c`:
#> b ~ a ~ c
#> 
#>   from to cov_operator cov_value stack components
#> 1    b  a           >=         0 FALSE          1
#> 2    a  c           >=         0 FALSE          1
```
