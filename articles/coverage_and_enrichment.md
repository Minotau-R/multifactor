# Coverage and enrichment testing

## Overview

### Setup

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`multifactor`](https://minotau-r.github.io/multifactor/)`)`\
\
`# Wrangling`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`\
\
`# Plotting`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`patchwork`](https://patchwork.data-imaginist.com)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`systemfonts`](https://github.com/r-lib/systemfonts)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ragg`](https://ragg.r-lib.org)`)`\
\
`# Load demo data`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``2612``)`\
`fox`` ``<-`` `[`quickbrownfox`](https://minotau-r.github.io/multifactor/reference/quickbrownfox.md)`(``)`\
\
`# Define utility function`\
`split_to_letters`` ``<-`` ``function``(``x``)`` `[`unique`](https://rdrr.io/r/base/unique.html)`(`\
`  `[`unlist`](https://rdrr.io/r/base/unlist.html)`(`\
`    `[`strsplit`](https://rdrr.io/r/base/strsplit.html)`(`[`gsub`](https://rdrr.io/r/base/grep.html)`(``" "``, ``""``, ``x``)``, split ``=`` ``""``)``,`\
`    recursive ``=`` ``TRUE``, use.names ``=`` ``FALSE`\
`  ``)`\
`)`

#### Example Dataset: The Quick Brown Fox

![](coverage_and_enrichment_files/figure-html/prep-plots-1.png)

\
[`levels`](https://rdrr.io/r/base/levels.html)`(``fox``)`\
`#> $letter`\
`#>  [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s"`\
`#> [20] "t" "u" "v" "w" "x" "y" "z"`\
`#> `\
`#> $word`\
`#> [1] "brown" "dog"   "fox"   "jumps" "lazy"  "over"  "quick" "the"  `\
`#> `\
`#> $constituent`\
`#> [1] "object"    "predicate" "subject"  `\
`#> `\
`#> $sentence`\
`#> [1] "complete pangram"`\
\
[`as.matrix`](https://rdrr.io/r/base/matrix.html)`(``fox``$``letter2word``)`\
`#> 26 x 8 sparse Matrix of class "ngCMatrix"`\
`#>       word`\
`#> letter brown dog fox jumps lazy over quick the`\
`#>      a     .   .   .     .    |    .     .   .`\
`#>      b     |   .   .     .    .    .     .   .`\
`#>      c     .   .   .     .    .    .     |   .`\
`#>      d     .   |   .     .    .    .     .   .`\
`#>      e     .   .   .     .    .    |     .   |`\
`#>      f     .   .   |     .    .    .     .   .`\
`#>      g     .   |   .     .    .    .     .   .`\
`#>      h     .   .   .     .    .    .     .   |`\
`#>      i     .   .   .     .    .    .     |   .`\
`#>      j     .   .   .     |    .    .     .   .`\
`#>      k     .   .   .     .    .    .     |   .`\
`#>      l     .   .   .     .    |    .     .   .`\
`#>      m     .   .   .     |    .    .     .   .`\
`#>      n     |   .   .     .    .    .     .   .`\
`#>      o     |   |   |     .    .    |     .   .`\
`#>      p     .   .   .     |    .    .     .   .`\
`#>      q     .   .   .     .    .    .     |   .`\
`#>      r     |   .   .     .    .    |     .   .`\
`#>      s     .   .   .     |    .    .     .   .`\
`#>      t     .   .   .     .    .    .     .   |`\
`#>      u     .   .   .     |    .    .     |   .`\
`#>      v     .   .   .     .    .    |     .   .`\
`#>      w     |   .   .     .    .    .     .   .`\
`#>      x     .   .   |     .    .    .     .   .`\
`#>      y     .   .   .     .    |    .     .   .`\
`#>      z     .   .   .     .    |    .     .   .`

#### Calculate coverage

We’ll need to generate some collection of letters as input data.

\
`input`` ``<-`` ``split_to_letters``(``"some collection of letters"``)`\
\
`input`\
`#>  [1] "s" "o" "m" "e" "c" "l" "t" "i" "n" "f" "r"`

We can use the
[`weave_coverage()`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)
function to calculate to what degree the input letters cover the words
in our data set. This function behaves similarly to
[`weave()`](https://minotau-r.github.io/multifactor/reference/weave-generic.md)
but comes with an additional argument, `.data`. For now, let’s plug in
our input letters:

\
`res`` ``<-`` `[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``word``, .data ``=`` ``input`\
`)`\
\
`res`\
`#> A multifactor::linkmap data.frame S7_object: 32 rows.`\
`#>    letter  word`\
`#> 1       t   the`\
`#> 2       h   the`\
`#> 3       e   the`\
`#> 4       q quick`\
`#> 5       u quick`\
`#> 6       i quick`\
`#> 7       c quick`\
`#> 8       k quick`\
`#> 9       b brown`\
`#> 10      r brown`\
`` #>  + 22 more rows. Use `print(n = ...)` to see more rows. ``\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ letter : 26 Levels: a ... z `\
`#>  $ word   :  8 Levels: brown ... the `\
`#> `\
`#> @ metadata: 5 variables: `\
`#> List of 5`\
`#>  $ observed : logi  TRUE FALSE TRUE FALSE FALSE TRUE ...`\
`#>  $ set_count: int  2 2 2 2 2 2 2 2 3 3 ...`\
`#>  $ set_size : int  3 3 3 5 5 5 5 5 5 5 ...`\
`#>  $ coverage : num  0.667 0.667 0.667 0.4 0.4 ...`\
`#>  $ complete : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...`

Now, let’s use a second set of letters that are explicitly part of the
sentence:

\
`input`` ``<-`` ``split_to_letters``(``"jumps over"``)`\
\
`input`\
`#> [1] "j" "u" "m" "p" "s" "o" "v" "e" "r"`

\
`res`` ``<-`` `[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``word``, .data ``=`` ``input`\
`)`\
\
`res`\
`#> A multifactor::linkmap data.frame S7_object: 32 rows.`\
`#>    letter  word`\
`#> 1       t   the`\
`#> 2       h   the`\
`#> 3       e   the`\
`#> 4       q quick`\
`#> 5       u quick`\
`#> 6       i quick`\
`#> 7       c quick`\
`#> 8       k quick`\
`#> 9       b brown`\
`#> 10      r brown`\
`` #>  + 22 more rows. Use `print(n = ...)` to see more rows. ``\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ letter : 26 Levels: a ... z `\
`#>  $ word   :  8 Levels: brown ... the `\
`#> `\
`#> @ metadata: 5 variables: `\
`#> List of 5`\
`#>  $ observed : logi  FALSE FALSE TRUE FALSE TRUE FALSE ...`\
`#>  $ set_count: int  1 1 1 1 1 1 1 1 2 2 ...`\
`#>  $ set_size : int  3 3 3 5 5 5 5 5 5 5 ...`\
`#>  $ coverage : num  0.333 0.333 0.333 0.2 0.2 ...`\
`#>  $ complete : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...`

Notice that the column named `"complete"` marks two particular words as
complete now.

We can use the [`subset()`](https://rdrr.io/r/base/subset.html) method
for `linkmap` to automatically filter for complete cases:

\
[`subset`](https://rdrr.io/r/base/subset.html)`(``res``)`\
`#> A multifactor::linkmap data.frame S7_object: 9 rows.`\
`#>   letter  word`\
`#> 1      j jumps`\
`#> 2      u jumps`\
`#> 3      m jumps`\
`#> 4      p jumps`\
`#> 5      s jumps`\
`#> 6      o  over`\
`#> 7      v  over`\
`#> 8      e  over`\
`#> 9      r  over`\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ letter : 26 Levels: a ... z `\
`#>  $ word   :  8 Levels: brown ... the `\
`#> `\
`#> @ metadata: 5 variables: `\
`#> List of 5`\
`#>  $ observed : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...`\
`#>  $ set_count: int  5 5 5 5 5 4 4 4 4`\
`#>  $ set_size : int  5 5 5 5 5 4 4 4 4`\
`#>  $ coverage : num  1 1 1 1 1 1 1 1 1`\
`#>  $ complete : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...`
