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
  `'coverage'`, `'complete'`.

- out.format:

  `Character scalar`. One of `'linkmap'`, `'matrix'`.

- .data_column:

  `Character scalar`. if `.data` is a table, where to find feature IDs

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
#> @ metadata: 2 variables: 
#> List of 2
#>  $ observed : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ set_count: int  0 0 0 0 0 0 0 0 0 0 ...

# Now let's spike our hand with a royal straight flush
cheat <- draw_cards()[c(10, 11, 12, 13, 1)]
cheat
#> [1] "10♥️"    "Jack♥️"  "Queen♥️" "King♥️"  "Ace♥️"  

.path = card ~ rank ~ straight > 0.2
result <- weave_coverage(scores, .path, .data = cheat)
result
#> A multifactor::linkmap data.frame S7_object: 20 rows.
#>      card       straight
#> 1    Ace♥️ Royal straight
#> 2     10♥️ Royal straight
#> 3   Jack♥️ Royal straight
#> 4  Queen♥️ Royal straight
#> 5   King♥️ Royal straight
#> 6    Ace♠️ Royal straight
#> 7     10♠️ Royal straight
#> 8   Jack♠️ Royal straight
#> 9  Queen♠️ Royal straight
#> 10  King♠️ Royal straight
#>  + 10 more rows. Use `print(n = ...)` to see more rows.
#> 
#> @ levels:   2 variables: 
#>  $ card     : 52 Levels: Ace♥️ ... King♣️ 
#>  $ straight : 10 Levels: Ace to 5 ... Royal straight 
#> 
#> @ metadata: 5 variables: 
#> List of 5
#>  $ observed : logi  TRUE TRUE TRUE TRUE TRUE FALSE ...
#>  $ set_count: int  5 5 5 5 5 5 5 5 5 5 ...
#>  $ set_size : int  20 20 20 20 20 20 20 20 20 20 ...
#>  $ coverage : num  0.25 0.25 0.25 0.25 0.25 0.25 0.25 0.25 0.25 0.25 ...
#>  $ complete : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
test_enrich(result)
#>                  expected observed fold log_fold     p.value      p.adj
#> Ace to 5       0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> 2 to 6         0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> 3 to 7         0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> 4 to 8         0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> 5 to 9         0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> 6 to 10        0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> 7 to Jack      0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> 8 to Queen     0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> 9 to King      0.09615385      NaN  NaN      NaN 1.000000000 1.00000000
#> Royal straight 0.09615385     0.25  2.6 1.378512 0.005965463 0.05965463
```
