# Perform enrichtment analysis from a weave

Perform enrichtment analysis from a weave

## Arguments

- x:

  a `multifactor`

- .path:

  Either a `formula` or a `character vector` of length 2 with the names
  of the desired combination of feature types.

- .data:

  Optional `Character vector`. Lists observed features from the found
  within the first element of `.path`. Alternatively, a `data.frame`
  with the same information. (Also see `.data_column` argument).

- metric:

  `Character scalar`. One or more of `'set_count'`, `'set_size'`,
  `'coverage'`. All are returned by default.

- out.format:

  `Character scalar`. One of `'linkmap'`, `'matrix'`.

- .data_column:

  `Character scalar`. if `.data` is a table, where to find feature IDs

- subset:

  `Logical scalar`. Whether to drop levels of the 'from' feature type
  that don't satisfy conditions in '.path' (Default: `TRUE`).
  [`test_enrich()`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)
  calls
  [`weave_coverage()`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)
  with `subset = FALSE`.

## Value

a `linkmap` or `matrix` with the desired coverage information in the
@metadata slot.

## Examples

``` r
# Load the quick brown fox data set
x <- quickbrownfox()
.data <- c("t", "h", "e", "f", "o", "x")
.path1 <- letter ~ word ~ constituent
.path2 <- letter ~ word : constituent
.path3 <- letter ~ word > 0.5 ~ constituent
.path4 <- letter : word ~ constituent > 0.25

weave_coverage(x = x, .path = .path1, .data = .data)
#> A multifactor::linkmap data.frame S7_object: 12 rows.
#>    letter constituent
#> 1       e      object
#> 2       h      object
#> 3       o      object
#> 4       t      object
#> 5       e   predicate
#> 6       o   predicate
#> 7       e     subject
#> 8       f     subject
#> 9       h     subject
#> 10      o     subject
#>  + 2 more rows. Use `print(n = ...)` to see more rows.
#> 
#> @ levels:   2 variables: 
#>  $ letter      : 26 Levels: a ... z 
#>  $ constituent :  3 Levels: object predicate subject 
#> 
#>  and  4  metadata variables.
weave_coverage(x = x, .path = .path2, .data = .data)
#> A multifactor::linkmap data.frame S7_object: 12 rows.
#>    letter constituent
#> 1       e      object
#> 2       h      object
#> 3       o      object
#> 4       t      object
#> 5       e   predicate
#> 6       o   predicate
#> 7       e     subject
#> 8       f     subject
#> 9       h     subject
#> 10      o     subject
#>  + 2 more rows. Use `print(n = ...)` to see more rows.
#> 
#> @ levels:   2 variables: 
#>  $ letter      : 26 Levels: a ... z 
#>  $ constituent :  3 Levels: object predicate subject 
#> 
#>  and  4  metadata variables.
weave_coverage(x = x, .path = .path3, .data = .data)
#> A multifactor::linkmap data.frame S7_object: 9 rows.
#>   letter constituent
#> 1      e      object
#> 2      h      object
#> 3      t      object
#> 4      e     subject
#> 5      f     subject
#> 6      h     subject
#> 7      o     subject
#> 8      t     subject
#> 9      x     subject
#> 
#> @ levels:   2 variables: 
#>  $ letter      : 26 Levels: a ... z 
#>  $ constituent :  3 Levels: object predicate subject 
#> 
#>  and  4  metadata variables.
weave_coverage(x = x, .path = .path4, .data = .data)
#> A multifactor::linkmap data.frame S7_object: 9 rows.
#>   letter constituent
#> 1      e      object
#> 2      h      object
#> 3      t      object
#> 4      e     subject
#> 5      f     subject
#> 6      h     subject
#> 7      o     subject
#> 8      t     subject
#> 9      x     subject
#> 
#> @ levels:   2 variables: 
#>  $ letter      : 26 Levels: a ... z 
#>  $ constituent :  3 Levels: object predicate subject 
#> 
#>  and  4  metadata variables.
```
