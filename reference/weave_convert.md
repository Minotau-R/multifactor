# Expand a table based on possibly overlapping group membership.

Expand a table into a tidy table suitable for tidyverse-style
operations.

## Usage

``` r
weave_convert(x, .path, .data, .transform = NULL, .index = "row.names")
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

- .transform:

  `An expression` detailing whether numerical values should be
  transformed in addition to being linked to other feature types.
  Leaving this at `NULL` indicates no transformation (Default).

- .index:

  `Character scalar` Column to look for feature IDs to link. Default:
  "row.names".

## Value

An expanded table `x`, with an added first column containing subgroups.

## Examples

``` r
# Prepare data
set.seed(2612)
x <- trade_posts()

# Generate small example feature table 'df'.
n <- nlevels(x)[["fruit"]]
df <- replicate(10, rbinom(n, rbinom(n, 100, runif(n)), runif(n)))

# Ensure feature names correspond to the first (LHS) variable in the formula.
df <- as.data.frame(df, row.names = levels(x)$fruit)

# Return a table with two feature type columns.
weave_convert(x, .path = fruit ~ clothing, .data = df)
#>      fruit clothing V1 V2 V3 V4 V5 V6 V7 V8 V9 V10
#> 1   apples    dress 10 29  5  4 52 72 30  6 53  44
#> 2   apples   gloves 10 29  5  4 52 72 30  6 53  44
#> 3   apples      hat 10 29  5  4 52 72 30  6 53  44
#> 4   apples    scarf 10 29  5  4 52 72 30  6 53  44
#> 5   apples  t-shirt 10 29  5  4 52 72 30  6 53  44
#> 6    pears   gloves 14  5 31 19  3 65  2 43 11  16
#> 7    pears      hat 14  5 31 19  3 65  2 43 11  16
#> 8    pears    scarf 14  5 31 19  3 65  2 43 11  16
#> 9    pears  t-shirt 14  5 31 19  3 65  2 43 11  16
#> 10 oranges    dress  2 13  8  4  2 21 13 45  5  38
#> 11 oranges      hat  2 13  8  4  2 21 13 45  5  38
#> 12 oranges    scarf  2 13  8  4  2 21 13 45  5  38
#> 13  melons    dress 15  2 12 30 40 73  8 28 13  92
#> 14  melons      hat 15  2 12 30 40 73  8 28 13  92
#> 15  melons    scarf 15  2 12 30 40 73  8 28 13  92
#> 16  grapes    dress  4 18 43 12 56 36  1  2 24  28
#> 17  grapes      hat  4 18 43 12 56 36  1  2 24  28
#> 18  grapes    scarf  4 18 43 12 56 36  1  2 24  28
```
