# Expand a table based on possibly overlapping group membership.

Expand a table into a tidy table suitable for tidyverse-stype
operations.

## Usage

``` r
weave_to_tbl(x, .path, .data, .index = "row.names")
```

## Arguments

- x:

  a `multifactor`.

- .path:

  either a `formula` or a \`character vector“ of length 2 with the names
  of the desired combination of feature types.

- .data:

  `A table`. A `data.frame`, `matrix`, other object with rows and
  columns. Should have a `cbind` method.

- .index:

  `Character scalar` Column to look for feature IDs to link. Default:
  "row.names".

## Value

An expanded table `x`, with an added first column containing subgroups.

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
weave_to_tbl(x, .path = fruit ~ clothing, .data = df)
#>       fruit clothing V1 V2 V3 V4 V5 V6 V7 V8 V9 V10
#> 1    apples  t-shirt 23 52  4  7 25  2  7 24 75  51
#> 2     pears  t-shirt 23 52  4  7 25  2  7 24 75  51
#> 3  cherries  t-shirt 23 52  4  7 25  2  7 24 75  51
#> 4    melons  t-shirt 23 52  4  7 25  2  7 24 75  51
#> 5    grapes  t-shirt 23 52  4  7 25  2  7 24 75  51
#> 6  cherries    dress  9 53 11 12 39  5 27 53 15  62
#> 7    apples    socks 42 30  0 12  2 41 20 67  2   2
#> 8     pears    socks 42 30  0 12  2 41 20 67  2   2
#> 9  cherries    socks 42 30  0 12  2 41 20 67  2   2
#> 10   melons    socks 42 30  0 12  2 41 20 67  2   2
#> 11   grapes    socks 42 30  0 12  2 41 20 67  2   2
#> 12   apples   gloves 20 49 42 26 25 26 46  1 11   7
#> 13   grapes   gloves 20 49 42 26 25 26 46  1 11   7
#> 14   apples      hat 36  0 47 24 13  4 54  0 55  46
#> 15    pears      hat 36  0 47 24 13  4 54  0 55  46
#> 16 cherries      hat 36  0 47 24 13  4 54  0 55  46
#> 17   melons      hat 36  0 47 24 13  4 54  0 55  46
#> 18   grapes      hat 36  0 47 24 13  4 54  0 55  46
#> 19 cherries    scarf 20 73 34 24 10 60  9 40 12  34
#> 20  oranges  t-shirt 23 52  4  7 25  2  7 24 75  51
#> 21   apples    dress  9 53 11 12 39  5 27 53 15  62
#> 22  oranges    dress  9 53 11 12 39  5 27 53 15  62
#> 23   melons    dress  9 53 11 12 39  5 27 53 15  62
#> 24   grapes    dress  9 53 11 12 39  5 27 53 15  62
#> 25   melons   gloves 20 49 42 26 25 26 46  1 11   7
#> 26   apples    scarf 20 73 34 24 10 60  9 40 12  34
#> 27  oranges    scarf 20 73 34 24 10 60  9 40 12  34
#> 28   melons    scarf 20 73 34 24 10 60  9 40 12  34
#> 29   grapes    scarf 20 73 34 24 10 60  9 40 12  34
```
