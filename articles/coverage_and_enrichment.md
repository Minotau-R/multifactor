# Coverage and enrichment testing

## Overview

Among other things, the multifactor package provides a set of tools to
calculate coverage and estimate enrichment for relational datasets. This
type of operation forms the basis for bioinformatics techniques such as
pathway enrichment analysis (PEA), but have application far beyond the
biological sciences.

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
`# Define utility function`\
`split_to_letters`` ``<-`` ``function``(``x``)`` `[`unique`](https://rdrr.io/r/base/unique.html)`(`\
`  `[`unlist`](https://rdrr.io/r/base/unlist.html)`(`\
`    `[`strsplit`](https://rdrr.io/r/base/strsplit.html)`(`[`gsub`](https://rdrr.io/r/base/grep.html)`(``" "``, ``""``, ``x``)``, split ``=`` ``""``)``,`\
`    recursive ``=`` ``TRUE``, use.names ``=`` ``FALSE`\
`  ``)`\
`)`

#### Example Dataset: The Quick Brown Fox

We will use a toy data set of hierarchically structured data, namely the
sentence: ‘The quick brown fox jumps over the lazy dog.’ This sentence
is a pangram, meaning that all 26 letters of the English alphabet are
represented. Moreover, we have deconstructed the sentence to three
levels; letters, words and constituents.

\
`# Load the quick brown fox data set`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``2612``)`\
`fox`` ``<-`` `[`quickbrownfox`](https://minotau-r.github.io/multifactor/reference/quickbrownfox.md)`(``)`

We could represent these relations visually like so:

![](coverage_and_enrichment_files/figure-html/prep-plots-1.png)

We can convince ourselves this same information is captured in the
multifactor object, `fox`.

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

### Calculate coverage

With coverage, we mean the proportion of items in a set that are
present. In other words, going back to our example, given some number of
letters, we can calculate which words we can make, and how complete they
are.

To demonstrate, we’ll need to generate some collection of letters as
input data:

\
`# Generate some collection of letters`\
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
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``res``)`\
`#>    letter  word observed set_count set_size  coverage complete`\
`#> 1       t   the     TRUE         2        3 0.6666667    FALSE`\
`#> 2       h   the    FALSE         2        3 0.6666667    FALSE`\
`#> 3       e   the     TRUE         2        3 0.6666667    FALSE`\
`#> 4       q quick    FALSE         2        5 0.4000000    FALSE`\
`#> 5       u quick    FALSE         2        5 0.4000000    FALSE`\
`#> 6       i quick     TRUE         2        5 0.4000000    FALSE`\
`#> 7       c quick     TRUE         2        5 0.4000000    FALSE`\
`#> 8       k quick    FALSE         2        5 0.4000000    FALSE`\
`#> 9       b brown    FALSE         3        5 0.6000000    FALSE`\
`#> 10      r brown     TRUE         3        5 0.6000000    FALSE`\
`#> 11      o brown     TRUE         3        5 0.6000000    FALSE`\
`#> 12      w brown    FALSE         3        5 0.6000000    FALSE`\
`#> 13      n brown     TRUE         3        5 0.6000000    FALSE`\
`#> 14      f   fox     TRUE         2        3 0.6666667    FALSE`\
`#> 15      o   fox     TRUE         2        3 0.6666667    FALSE`\
`#> 16      x   fox    FALSE         2        3 0.6666667    FALSE`\
`#> 17      j jumps    FALSE         2        5 0.4000000    FALSE`\
`#> 18      u jumps    FALSE         2        5 0.4000000    FALSE`\
`#> 19      m jumps     TRUE         2        5 0.4000000    FALSE`\
`#> 20      p jumps    FALSE         2        5 0.4000000    FALSE`\
`#> 21      s jumps     TRUE         2        5 0.4000000    FALSE`\
`#> 22      o  over     TRUE         3        4 0.7500000    FALSE`\
`#> 23      v  over    FALSE         3        4 0.7500000    FALSE`\
`#> 24      e  over     TRUE         3        4 0.7500000    FALSE`\
`#> 25      r  over     TRUE         3        4 0.7500000    FALSE`\
`#> 26      l  lazy     TRUE         1        4 0.2500000    FALSE`\
`#> 27      a  lazy    FALSE         1        4 0.2500000    FALSE`\
`#> 28      z  lazy    FALSE         1        4 0.2500000    FALSE`\
`#> 29      y  lazy    FALSE         1        4 0.2500000    FALSE`\
`#> 30      d   dog    FALSE         1        3 0.3333333    FALSE`\
`#> 31      o   dog     TRUE         1        3 0.3333333    FALSE`\
`#> 32      g   dog    FALSE         1        3 0.3333333    FALSE`

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
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``res``)`\
`#>    letter  word observed set_count set_size  coverage complete`\
`#> 1       t   the    FALSE         1        3 0.3333333    FALSE`\
`#> 2       h   the    FALSE         1        3 0.3333333    FALSE`\
`#> 3       e   the     TRUE         1        3 0.3333333    FALSE`\
`#> 4       q quick    FALSE         1        5 0.2000000    FALSE`\
`#> 5       u quick     TRUE         1        5 0.2000000    FALSE`\
`#> 6       i quick    FALSE         1        5 0.2000000    FALSE`\
`#> 7       c quick    FALSE         1        5 0.2000000    FALSE`\
`#> 8       k quick    FALSE         1        5 0.2000000    FALSE`\
`#> 9       b brown    FALSE         2        5 0.4000000    FALSE`\
`#> 10      r brown     TRUE         2        5 0.4000000    FALSE`\
`#> 11      o brown     TRUE         2        5 0.4000000    FALSE`\
`#> 12      w brown    FALSE         2        5 0.4000000    FALSE`\
`#> 13      n brown    FALSE         2        5 0.4000000    FALSE`\
`#> 14      f   fox    FALSE         1        3 0.3333333    FALSE`\
`#> 15      o   fox     TRUE         1        3 0.3333333    FALSE`\
`#> 16      x   fox    FALSE         1        3 0.3333333    FALSE`\
`#> 17      j jumps     TRUE         5        5 1.0000000     TRUE`\
`#> 18      u jumps     TRUE         5        5 1.0000000     TRUE`\
`#> 19      m jumps     TRUE         5        5 1.0000000     TRUE`\
`#> 20      p jumps     TRUE         5        5 1.0000000     TRUE`\
`#> 21      s jumps     TRUE         5        5 1.0000000     TRUE`\
`#> 22      o  over     TRUE         4        4 1.0000000     TRUE`\
`#> 23      v  over     TRUE         4        4 1.0000000     TRUE`\
`#> 24      e  over     TRUE         4        4 1.0000000     TRUE`\
`#> 25      r  over     TRUE         4        4 1.0000000     TRUE`\
`#> 26      l  lazy    FALSE         0        4 0.0000000    FALSE`\
`#> 27      a  lazy    FALSE         0        4 0.0000000    FALSE`\
`#> 28      z  lazy    FALSE         0        4 0.0000000    FALSE`\
`#> 29      y  lazy    FALSE         0        4 0.0000000    FALSE`\
`#> 30      d   dog    FALSE         1        3 0.3333333    FALSE`\
`#> 31      o   dog     TRUE         1        3 0.3333333    FALSE`\
`#> 32      g   dog    FALSE         1        3 0.3333333    FALSE`

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

### Enrichment testing

The
[`test_enrich()`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)
allows for quick hypothesis testing using the same syntax:

\
[`test_enrich`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)`(``x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``word``, .data ``=`` ``input``)`\
`#>        expected  observed      fold    log_fold     p.value      p.adj`\
`#> brown 0.3461538 0.4000000 1.1555556  0.20858662 0.580297963 0.98461538`\
`#> dog   0.3461538 0.3333333 0.9629630 -0.05444778 0.738461538 0.98461538`\
`#> fox   0.3461538 0.3333333 0.9629630 -0.05444778 0.738461538 0.98461538`\
`#> jumps 0.3461538 1.0000000 2.8888889  1.53051472 0.001915476 0.01532381`\
`#> lazy  0.3461538 0.0000000 0.0000000        -Inf 1.000000000 1.00000000`\
`#> over  0.3461538 1.0000000 2.8888889  1.53051472 0.008428094 0.03371237`\
`#> quick 0.3461538 0.2000000 0.5777778 -0.79141338 0.905928854 1.00000000`\
`#> the   0.3461538 0.3333333 0.9629630 -0.05444778 0.738461538 0.98461538`

Alternatively,
[`test_enrich()`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)
can also be run on the result of an earlier
[`weave_coverage()`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)
call for the same results:

\
[`test_enrich`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)`(``res``)`\
`#>        expected  observed      fold    log_fold     p.value      p.adj`\
`#> brown 0.3461538 0.4000000 1.1555556  0.20858662 0.580297963 0.98461538`\
`#> dog   0.3461538 0.3333333 0.9629630 -0.05444778 0.738461538 0.98461538`\
`#> fox   0.3461538 0.3333333 0.9629630 -0.05444778 0.738461538 0.98461538`\
`#> jumps 0.3461538 1.0000000 2.8888889  1.53051472 0.001915476 0.01532381`\
`#> lazy  0.3461538 0.0000000 0.0000000        -Inf 1.000000000 1.00000000`\
`#> over  0.3461538 1.0000000 2.8888889  1.53051472 0.008428094 0.03371237`\
`#> quick 0.3461538 0.2000000 0.5777778 -0.79141338 0.905928854 1.00000000`\
`#> the   0.3461538 0.3333333 0.9629630 -0.05444778 0.738461538 0.98461538`

### Defining coverage

By default, coverage is only calculated between the data types involved
in the last step of the path:

\
`path`` ``<-`` `[`select_path`](https://minotau-r.github.io/multifactor/reference/select_path-generic.md)`(``fox``, ``letter`` ``~`` ``constituent``)`\
`path`\
`#> A multifactor::path_frame S7_object.`\
`` #>   A path from `letter` to `constituent`: ``\
`#> letter ~ word ~ constituent`\
`#> `\
`#>     from          to cov_operator cov_value stack components`\
`#> 1 letter        word           >=         0 FALSE          1`\
`#> 2   word constituent           >=         0 FALSE          1`\
\
`input_full`` ``<-`` ``split_to_letters``(``"jumps over"``)`\
`input_no_r`` ``<-`` ``split_to_letters``(``"jumps ove"``)`\
\
`res_full`` ``<-`` `[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``constituent``, .data ``=`` ``input_full`\
`)`\
\
`res_no_r`` ``<-`` `[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``constituent``, .data ``=`` ``input_no_r`\
`)`\
\
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``res_full``)`\
`#>    letter constituent observed set_count set_size  coverage complete`\
`#> 1       a      object    FALSE         2       10 0.2000000    FALSE`\
`#> 2       d      object    FALSE         2       10 0.2000000    FALSE`\
`#> 3       e      object     TRUE         2       10 0.2000000    FALSE`\
`#> 4       g      object    FALSE         2       10 0.2000000    FALSE`\
`#> 5       h      object    FALSE         2       10 0.2000000    FALSE`\
`#> 6       l      object    FALSE         2       10 0.2000000    FALSE`\
`#> 7       o      object     TRUE         2       10 0.2000000    FALSE`\
`#> 8       t      object    FALSE         2       10 0.2000000    FALSE`\
`#> 9       y      object    FALSE         2       10 0.2000000    FALSE`\
`#> 10      z      object    FALSE         2       10 0.2000000    FALSE`\
`#> 11      e   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 12      j   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 13      m   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 14      o   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 15      p   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 16      r   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 17      s   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 18      u   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 19      v   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 20      b     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 21      c     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 22      e     subject     TRUE         4       15 0.2666667    FALSE`\
`#> 23      f     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 24      h     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 25      i     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 26      k     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 27      n     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 28      o     subject     TRUE         4       15 0.2666667    FALSE`\
`#> 29      q     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 30      r     subject     TRUE         4       15 0.2666667    FALSE`\
`#> 31      t     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 32      u     subject     TRUE         4       15 0.2666667    FALSE`\
`#> 33      w     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 34      x     subject    FALSE         4       15 0.2666667    FALSE`\
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``res_no_r``)`\
`#>    letter constituent observed set_count set_size  coverage complete`\
`#> 1       a      object    FALSE         2       10 0.2000000    FALSE`\
`#> 2       d      object    FALSE         2       10 0.2000000    FALSE`\
`#> 3       e      object     TRUE         2       10 0.2000000    FALSE`\
`#> 4       g      object    FALSE         2       10 0.2000000    FALSE`\
`#> 5       h      object    FALSE         2       10 0.2000000    FALSE`\
`#> 6       l      object    FALSE         2       10 0.2000000    FALSE`\
`#> 7       o      object     TRUE         2       10 0.2000000    FALSE`\
`#> 8       t      object    FALSE         2       10 0.2000000    FALSE`\
`#> 9       y      object    FALSE         2       10 0.2000000    FALSE`\
`#> 10      z      object    FALSE         2       10 0.2000000    FALSE`\
`#> 11      e   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 12      j   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 13      m   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 14      o   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 15      p   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 16      r   predicate    FALSE         8        9 0.8888889    FALSE`\
`#> 17      s   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 18      u   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 19      v   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 20      b     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 21      c     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 22      e     subject     TRUE         3       15 0.2000000    FALSE`\
`#> 23      f     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 24      h     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 25      i     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 26      k     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 27      n     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 28      o     subject     TRUE         3       15 0.2000000    FALSE`\
`#> 29      q     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 30      r     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 31      t     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 32      u     subject     TRUE         3       15 0.2000000    FALSE`\
`#> 33      w     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 34      x     subject    FALSE         3       15 0.2000000    FALSE`

\
`path2`` ``<-`` ``letter`` ``~`` ``word`` ``>=`` ``0`` ``~`` ``constituent`` ``>=`` ``0`\
`path2`\
`#> letter ~ word >= 0 ~ constituent >= 0`\
\
`res_full`` ``<-`` `[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``path2``, .data ``=`` ``input_full`\
`)`\
\
`res_no_r`` ``<-`` `[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``path2``, .data ``=`` ``input_no_r`\
`)`\
\
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``res_full``)`\
`#>    letter constituent observed set_count set_size  coverage complete`\
`#> 1       a      object    FALSE         2       10 0.2000000    FALSE`\
`#> 2       d      object    FALSE         2       10 0.2000000    FALSE`\
`#> 3       e      object     TRUE         2       10 0.2000000    FALSE`\
`#> 4       g      object    FALSE         2       10 0.2000000    FALSE`\
`#> 5       h      object    FALSE         2       10 0.2000000    FALSE`\
`#> 6       l      object    FALSE         2       10 0.2000000    FALSE`\
`#> 7       o      object     TRUE         2       10 0.2000000    FALSE`\
`#> 8       t      object    FALSE         2       10 0.2000000    FALSE`\
`#> 9       y      object    FALSE         2       10 0.2000000    FALSE`\
`#> 10      z      object    FALSE         2       10 0.2000000    FALSE`\
`#> 11      e   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 12      j   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 13      m   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 14      o   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 15      p   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 16      r   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 17      s   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 18      u   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 19      v   predicate     TRUE         9        9 1.0000000     TRUE`\
`#> 20      b     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 21      c     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 22      e     subject     TRUE         4       15 0.2666667    FALSE`\
`#> 23      f     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 24      h     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 25      i     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 26      k     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 27      n     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 28      o     subject     TRUE         4       15 0.2666667    FALSE`\
`#> 29      q     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 30      r     subject     TRUE         4       15 0.2666667    FALSE`\
`#> 31      t     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 32      u     subject     TRUE         4       15 0.2666667    FALSE`\
`#> 33      w     subject    FALSE         4       15 0.2666667    FALSE`\
`#> 34      x     subject    FALSE         4       15 0.2666667    FALSE`\
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``res_no_r``)`\
`#>    letter constituent observed set_count set_size  coverage complete`\
`#> 1       a      object    FALSE         2       10 0.2000000    FALSE`\
`#> 2       d      object    FALSE         2       10 0.2000000    FALSE`\
`#> 3       e      object     TRUE         2       10 0.2000000    FALSE`\
`#> 4       g      object    FALSE         2       10 0.2000000    FALSE`\
`#> 5       h      object    FALSE         2       10 0.2000000    FALSE`\
`#> 6       l      object    FALSE         2       10 0.2000000    FALSE`\
`#> 7       o      object     TRUE         2       10 0.2000000    FALSE`\
`#> 8       t      object    FALSE         2       10 0.2000000    FALSE`\
`#> 9       y      object    FALSE         2       10 0.2000000    FALSE`\
`#> 10      z      object    FALSE         2       10 0.2000000    FALSE`\
`#> 11      e   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 12      j   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 13      m   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 14      o   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 15      p   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 16      r   predicate    FALSE         8        9 0.8888889    FALSE`\
`#> 17      s   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 18      u   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 19      v   predicate     TRUE         8        9 0.8888889    FALSE`\
`#> 20      b     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 21      c     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 22      e     subject     TRUE         3       15 0.2000000    FALSE`\
`#> 23      f     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 24      h     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 25      i     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 26      k     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 27      n     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 28      o     subject     TRUE         3       15 0.2000000    FALSE`\
`#> 29      q     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 30      r     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 31      t     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 32      u     subject     TRUE         3       15 0.2000000    FALSE`\
`#> 33      w     subject    FALSE         3       15 0.2000000    FALSE`\
`#> 34      x     subject    FALSE         3       15 0.2000000    FALSE`
