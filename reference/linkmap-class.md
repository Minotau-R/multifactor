# linkmap S7 container class

`linkmap` is an S7 class to organize and manage multiple sets of
factors, for instance when tracing or converting feature IDs across
databases. Methods for `linkmap` aim to follow `factor` behaviour.

## Usage

``` r
linkmap(x, metadata = NULL)
```

## Arguments

- x:

  `data.frame` with two named columns that can be coerced to factors.
  Optionally, additional columns will be stored as metadata.

- metadata:

  Optional `data.frame` with same number of rows as x. Contains
  information about the feature link in that row.

## Value

a `linkmap` object.

## Slots

- `levels`:

  `Named list` of character vectors depicting levels.

- `metadata`:

  `data.frame`. Optional. Used to store additional data or
  application-specific tags.

## See also

[`multifactor()`](https://minotau-r.github.io/multifactor/reference/multifactor-class.md)

## Examples

``` r
# Generate random linkage input
x <- data.frame(
  a = sample(letters[seq(3)], 10, replace = TRUE),
  A = sample(LETTERS[seq(3)], 10, replace = TRUE)
)

# Create linkmap
linkmap(x)
#> A multifactor::linkmap data.frame S7_object: 7 rows.
#>   a A
#> 1 c C
#> 2 b C
#> 3 b B
#> 4 c B
#> 5 b A
#> 6 a B
#> 7 a C
#> 
#> @ levels:   2 variables: 
#>  $ a : 3 Levels: c b a 
#>  $ A : 3 Levels: C B A 
```
