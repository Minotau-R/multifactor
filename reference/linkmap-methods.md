# Methods for linkmap S7 container class

Methods for linkmap S7 container class

## Arguments

- x, object:

  `linkmap` on which the method should be applied.

## Value

A `linkmap`

## Examples

``` r
# Setup
a2b <- data.frame(
  a = sample(letters[seq(3)], 10, replace = TRUE),
  b = sample(LETTERS[seq(3)], 10, replace = TRUE)
)

# Create linkmap
x <- linkmap(a2b)

# Basic properties
dim(x)
#> [1] 6 2
dimnames(x)
#> [[1]]
#> [1] "1" "2" "3" "4" "5" "6"
#> 
#> [[2]]
#> [1] "a" "b"
#> 

print(x)
#> A multifactor::linkmap data.frame S7_object: 6 rows.
#>   a b
#> 1 c C
#> 2 b B
#> 3 b A
#> 4 a C
#> 5 c B
#> 6 b C
#> 
#> @ levels:   2 variables: 
#>  $ a : 3 Levels: c b a 
#>  $ b : 3 Levels: C B A 

# Factor-like properties
levels(x)
#> $a
#> [1] "c" "b" "a"
#> 
#> $b
#> [1] "C" "B" "A"
#> 
nlevels(x)
#> a b 
#> 3 3 
```
