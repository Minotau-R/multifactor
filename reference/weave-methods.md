# Weave a new linkmap from a multifactor

Generates a new `linkmap` object by cross-referencing the elements of a
given `multifactor`.

## Arguments

- x:

  a `multifactor`

- .path:

  Either a `formula` or a `character vector` of length 2 with the names
  of the desired combination of feature types.

- out.format:

  `Character scalar`. One of `'linkmap'`, `'matrix'`.

- include, exclude, exact:

  `Character vectors` Should feature types be included or excluded from
  the available paths? Exact allows for exact path definition.

## Value

a `linkmap` or `sparse Matrix`.

## Examples

``` r
# Generate a random multifactor
x <- random_multifactor()

# Weave new b2c linkmap
weave(x, b ~ c)
#> A multifactor::linkmap data.frame S7_object: 25 rows.
#>        b     c
#> 1  b_006 c_001
#> 2  b_010 c_001
#> 3  b_005 c_002
#> 4  b_006 c_002
#> 5  b_009 c_004
#> 6  b_002 c_005
#> 7  b_006 c_005
#> 8  b_009 c_005
#> 9  b_003 c_006
#> 10 b_009 c_006
#>  + 15 more rows. Use `print(n = ...)` to see more rows.
#> 
#> @ levels:   2 variables: 
#>  $ b : 10 Levels: b_001 b_002 ... b_010 
#>  $ c : 10 Levels: c_001 c_002 ... c_010 
weave(x, b ~ a, out.format = "matrix")
#> 10 x 10 sparse Matrix of class "ngCMatrix"
#>   [[ suppressing 10 column names ‘a_001’, ‘a_002’, ‘a_003’ ... ]]
#>        a
#> b                          
#>   b_001 . . . . . | . . | .
#>   b_002 . . . . . . . . . .
#>   b_003 | . | . | | | | . |
#>   b_004 . . . . . . | . . .
#>   b_005 . . | . . | . . | .
#>   b_006 . . | . . . . | . |
#>   b_007 . . . . . | | | . .
#>   b_008 . . | . . . | . . |
#>   b_009 . . . . . . . | . .
#>   b_010 | | . . . . . . . .
```
