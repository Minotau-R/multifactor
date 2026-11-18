# Methods for path_frame S7 container class

Methods for path_frame S7 container class

## Arguments

- x, object:

  `path_frame` on which the method should be applied.

## Value

A `path_frame` or method-appropriate value.

## Examples

``` r
# Only necessary in example
require(generics)

x <- random_multifactor()

# Generate a path_frame
p <- select_path(x, a ~ d)

# Get formula notation for the full path:
formula(p)
#> a ~ b ~ c ~ d

# Split path into components
components(p)
#> $`1`
#> A multifactor::path_frame S7_object.
#>   A path from `a` to `d`:
#> [[1]]
#> a ~ b ~ c ~ d
#> 
#>   from to cov_operator cov_value stack component
#> 1    a  b           >=         0 FALSE         1
#> 2    b  c           >=         0 FALSE         1
#> 3    c  d           >=         0 FALSE         1
#> 
```
