# Example dataset using a famous pangram.

Demo data set used in the coverage en enrichment vignette.

## Usage

``` r
data("quickbrownfox", package = "multifactor")

quickbrownfox(raw.data = FALSE)
```

## Format

`quickbrownfox`: A multifactor of letters, words and constituents

## Source

`quickbrownfox`: Manually curated.

## Arguments

- raw.data:

  `Boolean`, Whether to return underlying `list` rather than the default
  `multifactor`.

## Examples

``` r
quickbrownfox()
#> A multifactor::multifactor list S7_object,
#>     4 feature types across 3 linkmaps.
#> 
#>                      letter word constituent sentence
#> letter2word              26    8           .        .
#> word2constituent          .    8           3        .
#> constituent2sentence      .    .           3        1
#> 
#> Values represent unique feature names in that linkmap.
#> 
#> @ levels:
#>  $ letter      : 26 Levels: a ... z 
#>  $ word        :  8 Levels: brown ... the 
#>  $ constituent :  3 Levels: object predicate subject 
#>  $ sentence    :  1 Levels: the quick brown fox jumps over the lazy dog 
```
