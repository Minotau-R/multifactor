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
set.seed(2612)
# Draw five cards from a deck
drawn <- draw_cards(5)
drawn
#> [1] "Jack♦️" "5♥️"    "King♠️" "7♥️"    "6♦️"   
scores <- poker_scores()
scores
#> A multifactor::multifactor list S7_object,
#>     4 feature types across 3 linkmaps.
#> 
#>               card rank suit straight
#> card2rank       52   13    .        .
#> card2suit       52    .    4        .
#> rank2straight    .   13    .       10
#> 
#> Values represent unique feature names in that linkmap.
#> 
#> @ levels:
#>  $ card     : 52 Levels: Ace♥️ ... King♣️ 
#>  $ rank     : 13 Levels: Ace ... King 
#>  $ suit     :  4 Levels: hearts spades diamonds clubs 
#>  $ straight : 10 Levels: Ace to 5 ... Royal straight 

# Now enrich input
result <- weave_coverage(
  x = scores, .path = card ~ suit, .data = drawn, metric = "set_count"
)

result
#> A multifactor::linkmap data.frame S7_object: 52 rows.
#>    card  suit
#> 1  Ace♣️ clubs
#> 2    2♣️ clubs
#> 3    3♣️ clubs
#> 4    4♣️ clubs
#> 5    5♣️ clubs
#> 6    6♣️ clubs
#> 7    7♣️ clubs
#> 8    8♣️ clubs
#> 9    9♣️ clubs
#> 10  10♣️ clubs
#>  + 42 more rows. Use `print(n = ...)` to see more rows.
#> 
#> @ levels:   2 variables: 
#>  $ card : 52 Levels: Ace♥️ ... King♣️ 
#>  $ suit :  4 Levels: hearts spades diamonds clubs 
#> 
#>  and  2  metadata variables.

# Now let's spike our hand with a royal straight flush
cheat <- draw_cards()[c(10, 11, 12, 13, 1)]
cheat
#> [1] "10♥️"    "Jack♥️"  "Queen♥️" "King♥️"  "Ace♥️"  

.path = card ~ rank ~ straight > 0.2
result <- weave_coverage(scores, .path, .data = cheat)
result
#> A multifactor::linkmap data.frame S7_object: 200 rows.
#>    card straight
#> 1  Ace♥️ Ace to 5
#> 2    2♥️ Ace to 5
#> 3    3♥️ Ace to 5
#> 4    4♥️ Ace to 5
#> 5    5♥️ Ace to 5
#> 6  Ace♠️ Ace to 5
#> 7    2♠️ Ace to 5
#> 8    3♠️ Ace to 5
#> 9    4♠️ Ace to 5
#> 10   5♠️ Ace to 5
#>  + 190 more rows. Use `print(n = ...)` to see more rows.
#> 
#> @ levels:   2 variables: 
#>  $ card     : 52 Levels: Ace♥️ ... King♣️ 
#>  $ straight : 10 Levels: Ace to 5 ... Royal straight 
#> 
#>  and  4  metadata variables.
test_enrich(result)
#>                  expected observed fold    log_fold     p.value      p.adj
#> Ace to 5       0.09615385     0.05 0.52 -0.94341647 0.922516699 1.00000000
#> 2 to 6         0.09615385     0.00 0.00        -Inf 1.000000000 1.00000000
#> 3 to 7         0.09615385     0.00 0.00        -Inf 1.000000000 1.00000000
#> 4 to 8         0.09615385     0.00 0.00        -Inf 1.000000000 1.00000000
#> 5 to 9         0.09615385     0.00 0.00        -Inf 1.000000000 1.00000000
#> 6 to 10        0.09615385     0.05 0.52 -0.94341647 0.922516699 1.00000000
#> 7 to Jack      0.09615385     0.10 1.04  0.05658353 0.645790624 1.00000000
#> 8 to Queen     0.09615385     0.15 1.56  0.64154603 0.283184043 0.94394681
#> 9 to King      0.09615385     0.20 2.08  1.05658353 0.065620094 0.32810047
#> Royal straight 0.09615385     0.25 2.60  1.37851162 0.005965463 0.05965463
```
