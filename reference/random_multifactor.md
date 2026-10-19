# Generate and optionally draw from a poker deck.

Randomly generate a valid `multifactor` or `linkmap` object.
`random_multifactor` can optionally take am `igraph` object to determine
its layout. (See examples) `trade_posts()` generates a random
`multifactor` in the style of the trading example from the vignette.

called by `random_multifactor`, shouldn't be called by user.

## Usage

``` r
draw_cards(draw = NULL)

poker_scores()

random_multifactor(layout = NULL, n_features = 10, sparseness = 0.75)

trade_posts(raw.data = FALSE)

random_linkmap(x = list(lower = letters, UPPER = LETTERS), sparseness = 0.5)

random_path_frame(
  n = 1L,
  n_steps = 2L,
  x = random_multifactor(),
  repeats = FALSE,
  p_cov = 0.5
)
```

## Arguments

- draw:

  Optional `integer`. How many cards to draw from the deck.

- layout:

  `igraph`, optional graph structure to generate random data for

- n_features:

  `Numeric scalar`, number of features per type

- sparseness:

  `Numeric scalar`, proportion: How rare are connections. Default is
  `0.5`.

- raw.data:

  `Boolean`, Whether to return the `data.frame` of goods rather than the
  default `multifactor`.

- x:

  `multifactor` to generate random paths through. Default is the result
  of `random_multifactor()`

- n:

  `Numeric scalar`, Integer: How many paths should be generated. Default
  is `1`.

- n_steps:

  `Numeric scalar`, Integer: How many steps should be generated. Note
  that actual path lengths are likely longer than the number of explicit
  nodes. Default is `2`.

- repeats:

  `Logical scalar`, Whether the same term can appear in `n_steps`.
  (Default: `FALSE`)

- p_cov:

  `Numeric scalar`, Proportion (between 0-1) of steps that should use
  coverage. (Default: 0.5).

## Value

a randomly generated object of the specified class.

## See also

[playing_cards](https://minotau-r.github.io/multifactor/reference/playing_cards.md)

[`multifactor()`](https://minotau-r.github.io/multifactor/reference/multifactor-class.md)

[`linkmap()`](https://minotau-r.github.io/multifactor/reference/linkmap-class.md)

## Examples

``` r
# Make a random multifactor object
x <- random_multifactor()
x
#> A multifactor::multifactor list S7_object,
#>     6 feature types across 5 linkmaps.
#> 
#>      a  b  c  d  e  f
#> a2b 10 10  .  .  .  .
#> b2c  . 10  9  .  .  .
#> c2d  .  . 10 10  .  .
#> d2e  .  .  .  9 10  .
#> e2f  .  .  .  .  8 10
#> 
#> Values represent unique feature names in that linkmap.
#> 
#> @ levels:
#>  $ a : 10 Levels: a_001 a_002 ... a_010 
#>  $ b : 10 Levels: b_001 b_002 ... b_010 
#>  $ c : 10 Levels: c_001 c_002 ... c_010 
#>  $ d : 10 Levels: d_001 d_002 ... d_010 
#>  $ e : 10 Levels: e_001 e_002 ... e_010 
#>  $ f : 10 Levels: f_001 f_002 ... f_010 

# Generate random paths through this multifactor
random_path_frame(n = 3, x = x)
#> [[1]]
#> A multifactor::path_frame S7_object.
#>   A path from `d` to `e`:
#> d ~ e
#> 
#>   from to cov_operator cov_value stack components
#> 1    d  e           >=         0 FALSE          1
#> 
#> [[2]]
#> A multifactor::path_frame S7_object.
#>   A path from `a` to `b`:
#> a ~ b
#> 
#>   from to cov_operator cov_value stack components
#> 1    a  b           >=         0 FALSE          1
#> 
#> [[3]]
#> A multifactor::path_frame S7_object.
#>   A path from `d` to `b`:
#> d ~ c ~ b
#> 
#>   from to cov_operator cov_value stack components
#> 1    d  c           >=         0 FALSE          1
#> 2    c  b           >=         0 FALSE          1
#> 

# Use a (possibly random) igraph as input:
random_multifactor(igraph::sample_gnp(6, 2 / 3))
#> A multifactor::multifactor list S7_object,
#>     6 feature types across 8 linkmaps.
#> 
#>       v1 v2 v4 v3 v5 v6
#> v12v2 10 10  .  .  .  .
#> v12v4 10  . 10  .  .  .
#> v22v4  .  9 10  .  .  .
#> v32v5  .  .  . 10 10  .
#> v22v5  . 10  .  . 10  .
#> v42v5  .  . 10  . 10  .
#> v32v6  .  .  .  9  .  9
#> v52v6  .  .  .  .  9  9
#> 
#> Values represent unique feature names in that linkmap.
#> 
#> @ levels:
#>  $ v1 : 10 Levels: v1_001 v1_002 ... v1_010 
#>  $ v2 : 10 Levels: v2_001 v2_002 ... v2_010 
#>  $ v4 : 10 Levels: v4_001 v4_002 ... v4_010 
#>  $ v3 : 10 Levels: v3_001 v3_002 ... v3_010 
#>  $ v5 : 10 Levels: v5_001 v5_002 ... v5_010 
#>  $ v6 : 10 Levels: v6_001 v6_002 ... v6_010 

# Make a random linkmap object
random_linkmap()
#> A multifactor::linkmap data.frame S7_object: 338 rows.
#>    lower UPPER
#> 1      j     A
#> 2      k     A
#> 3      n     A
#> 4      o     A
#> 5      p     A
#> 6      u     A
#> 7      w     A
#> 8      c     B
#> 9      e     B
#> 10     f     B
#>  + 328 more rows. Use `print(n = ...)` to see more rows.
#> 
#> @ levels:   2 variables: 
#>  $ lower : 26 Levels: j ... q 
#>  $ UPPER : 26 Levels: A ... Z 

# Make a random multifactor with the trading goods from the vignettes
trade_posts()
#> A multifactor::multifactor list S7_object,
#>     6 feature types across 6 linkmaps.
#> 
#>                      books clothing fruit furniture instruments marbles
#> books2clothing           6        5     .         .           .       .
#> books2fruit              5        .     5         .           .       .
#> fruit2furniture          .        .     5         5           .       .
#> books2instruments        5        .     .         .           5       .
#> clothing2instruments     .        5     .         .           6       .
#> clothing2marbles         .        4     .         .           .       4
#> 
#> Values represent unique feature names in that linkmap.
#> 
#> @ levels:
#>  $ books       : 6 Levels: fancy book ... plain book 
#>  $ clothing    : 6 Levels: t-shirt ... scarf 
#>  $ fruit       : 6 Levels: apples ... grapes 
#>  $ furniture   : 6 Levels: couch ... door 
#>  $ instruments : 6 Levels: trumpet ... saxophone 
#>  $ marbles     : 6 Levels: red marble ... sparkly marble 

# Playing cards
draw_cards(5)
#> [1] "10♣️" "8♥️"  "3♦️"  "6♥️"  "7♣️" 
poker_scores()
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
```
