# Combine levels across several linkmaps in a multifactor

Generates a new `linkmap` object by merging levels by name, separated by
the plus (`+`) sign. See examples.

## Arguments

- x:

  a `multifactor`

- .path:

  a `formula` of length 2 with with levels to be merged separated by the
  plus (`+`) sign. Optionally, a list with two character vectors,
  signifying the variables to be combined at the left and right hand
  side, respectively.

- ...:

  Additional arguments (unused.)

- out.format:

  `Character scalar`. One of `'linkmap'`, `'matrix'`.

## Value

a `linkmap` or `sparse Matrix`.

## Examples

``` r
# Only necessary in example code
require(utils)

x <- random_multifactor()
# Merge variables with "+" operator, new names get concatenated with ".":
stack(x, b ~ c + d)
#> A multifactor::linkmap data.frame S7_object: 70 rows.
#>        b   c.d
#> 1  b_001 c_001
#> 2  b_004 c_001
#> 3  b_005 c_002
#> 4  b_006 c_002
#> 5  b_008 c_002
#> 6  b_005 c_003
#> 7  b_004 c_004
#> 8  b_005 c_004
#> 9  b_010 c_004
#> 10 b_005 c_005
#>  + 60 more rows. Use `print(n = ...)` to see more rows.
#> 
#> @ levels:   2 variables: 
#>  $ b   : 10 Levels: b_001 b_002 ... b_010 
#>  $ c.d : 20 Levels: c_001 c_002 ... d_010 
```
