# Coverage and enrichment testing

## Overview

Among other things, `multifactor` provides a set of tools to calculate
coverage and estimate enrichment for relational data sets. This type of
operation forms the basis for bioinformatics techniques such as pathway
enrichment analysis (PEA), but have application far beyond the
biological sciences.

### Environment setup

To start with, we load the necessary libraries.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`multifactor`](https://github.com/Minotau-R/multifactor)`)`\
\
`# Wrangling`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`tidyr`](https://tidyr.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`stringr`](https://stringr.tidyverse.org)`)`\
\
`# Plotting`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`patchwork`](https://patchwork.data-imaginist.com)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggforce`](https://ggforce.data-imaginist.com)`)`\
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

#### Example data set: The Quick Brown Fox

We will use a toy data set of hierarchically structured data, namely the
sentence:

> The quick brown fox jumps over the lazy dog

This sentence is a *pangram*, meaning that all 26 letters of the English
alphabet are represented. Moreover, we have deconstructed the sentence
to three levels: letters, words and constituents.

\
`# Load the quick brown fox data set`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``2612``)`\
`fox`` ``<-`` `[`quickbrownfox`](https://minotau-r.github.io/multifactor/reference/quickbrownfox.md)`(``)`

We could represent these relations visually like so:

![](coverage_and_enrichment_files/figure-html/prep-plots-1.png)

We can convince ourselves this same information is captured in the
multifactor object, `fox`.

\
`# View levels`\
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
`#> [1] "the quick brown fox jumps over the lazy dog"`\
\
`# Convert linkmap to matrix`\
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

## Calculate coverage

### Introduction

With *coverage*, we mean the proportion of items in a set that are
present. In other words, going back to our example, given some number of
letters, we can calculate which words we can make, and how complete they
are.

To demonstrate, let’s first consider the graph representation of our
data set:
![](coverage_and_enrichment_files/figure-html/plot-cov-0-1.png)

Three feature types are shown on the x-axis, with links between
respective levels as lines. We can see that each letter is linked to the
words it appears in, which are in turn linked to their corresponding
constituents.

We’ll also need to generate some collection of letters as input data:

\
`# Generate some collection of letters`\
`input`` ``<-`` ``split_to_letters``(``"a pangram is a sentence with all letters"``)`\
\
`input`\
`#>  [1] "a" "p" "n" "g" "r" "m" "i" "s" "e" "t" "c" "w" "h" "l"`

### Defining coverage in a path

### Estimate coverage using `weave_coverage()`

We can use the
[`weave_coverage()`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)
function to calculate to what degree the input letters cover the words
in our data set. This function behaves similarly to
[`weave()`](https://minotau-r.github.io/multifactor/reference/weave-generic.md),
in the sense that it takes a `multifactor` as its first argument, `x`,
and its second argument, `.path`, defines the path through that
`multifactor`. It also has an additional argument, `.data`.

For now, let’s plug in our input letters:

\
`res`` ``<-`` `[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``word`` ``~`` ``constituent``, .data ``=`` ``input`\
`)`

![](coverage_and_enrichment_files/figure-html/weave-plot-specify1-1.png)

#### Filter using `subset()`

We can use the [`subset()`](https://rdrr.io/r/base/subset.html) method
for `linkmap` to automatically filter for complete cases, only the word
‘the’ is complete:

\
[`subset`](https://rdrr.io/r/base/subset.html)`(``res``)`\
`#> A multifactor::linkmap data.frame S7_object: 0 rows.`\
`#> [1] letter      constituent`\
`#> <0 rows> (or 0-length row.names)`\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ letter      : 26 Levels: a ... z `\
`#>  $ constituent :  3 Levels: object predicate subject`

By default, coverage is only calculated between the data types involved
in the last step of the path. However, we can specify conditional
filtering steps.

#### Complete coverage

When defining a path, we can use the `:` operator as shorthand for
complete coverage (`>= 1`). For example:
`letter ~ word ~ constituent >= 1` is equivalent to
`letter ~ word : constituent`.

\
[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``word`` ``:`` ``constituent``, .data ``=`` ``input`\
`)`\
`#> A multifactor::linkmap data.frame S7_object: 34 rows.`\
`#>    letter constituent`\
`#> 1       a      object`\
`#> 2       d      object`\
`#> 3       e      object`\
`#> 4       g      object`\
`#> 5       h      object`\
`#> 6       l      object`\
`#> 7       o      object`\
`#> 8       t      object`\
`#> 9       y      object`\
`#> 10      z      object`\
`` #>  + 24 more rows. Use `print(n = ...)` to see more rows. ``\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ letter      : 26 Levels: a ... z `\
`#>  $ constituent :  3 Levels: object predicate subject `\
`#> `\
`#>  and  4  metadata variables.`

![](coverage_and_enrichment_files/figure-html/weave-plot-specify2-1.png)

#### Advanced: partial coverage

We can similarly define threshold-based filters using relational
expressions. For example: `letter ~ word > 0.5 ~ constituent`.

\
[`weave_coverage`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)`(`\
`  x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``word`` ``>`` ``0.5`` ``~`` ``constituent``, .data ``=`` ``input`\
`)`\
`#> A multifactor::linkmap data.frame S7_object: 34 rows.`\
`#>    letter constituent`\
`#> 1       a      object`\
`#> 2       d      object`\
`#> 3       e      object`\
`#> 4       g      object`\
`#> 5       h      object`\
`#> 6       l      object`\
`#> 7       o      object`\
`#> 8       t      object`\
`#> 9       y      object`\
`#> 10      z      object`\
`` #>  + 24 more rows. Use `print(n = ...)` to see more rows. ``\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ letter      : 26 Levels: a ... z `\
`#>  $ constituent :  3 Levels: object predicate subject `\
`#> `\
`#>  and  4  metadata variables.`

![](coverage_and_enrichment_files/figure-html/weave-plot-specify3-1.png)

### Enrichment testing

The
[`test_enrich()`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)
allows for quick hypothesis testing using the same syntax:

\
[`test_enrich`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)`(``x ``=`` ``fox``, .path ``=`` ``letter`` ``~`` ``constituent``, .data ``=`` ``input``)`\
`#>            expected  observed      fold    log_fold   p.value     p.adj`\
`#> object    0.5384615 0.6000000 1.1142857  0.15611920 0.4640194 0.6759052`\
`#> predicate 0.5384615 0.5555556 1.0317460  0.04508789 0.6132723 0.6759052`\
`#> subject   0.5384615 0.5333333 0.9904762 -0.01380580 0.6759052 0.6759052`

Alternatively,
[`test_enrich()`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)
can also be run on the result of an earlier
[`weave_coverage()`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)
call for the same results:

\
[`test_enrich`](https://minotau-r.github.io/multifactor/reference/test_enrich-generic.md)`(``res``)`\
`#>            expected  observed      fold    log_fold   p.value     p.adj`\
`#> object    0.5384615 0.6000000 1.1142857  0.15611920 0.4640194 0.6759052`\
`#> predicate 0.5384615 0.5555556 1.0317460  0.04508789 0.6132723 0.6759052`\
`#> subject   0.5384615 0.5333333 0.9904762 -0.01380580 0.6759052 0.6759052`

## Session Info

\
[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`\
`#> R version 4.6.1 (2026-06-24)`\
`#> Platform: x86_64-pc-linux-gnu`\
`#> Running under: Ubuntu 24.04.5 LTS`\
`#> `\
`#> Matrix products: default`\
`#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 `\
`#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0`\
`#> `\
`#> locale:`\
`#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              `\
`#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    `\
`#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   `\
`#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 `\
`#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            `\
`#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       `\
`#> `\
`#> time zone: UTC`\
`#> tzcode source: system (glibc)`\
`#> `\
`#> attached base packages:`\
`#> [1] stats     graphics  grDevices utils     datasets  methods   base     `\
`#> `\
`#> other attached packages:`\
`#> [1] ragg_1.5.2        systemfonts_1.3.2 ggforce_0.5.0     patchwork_1.3.2  `\
`#> [5] ggplot2_4.0.3     stringr_1.6.0     tidyr_1.3.2       dplyr_1.2.1      `\
`#> [9] multifactor_0.1.3`\
`#> `\
`#> loaded via a namespace (and not attached):`\
`#>  [1] sass_0.4.10        generics_0.1.4     stringi_1.8.9      lattice_0.23-1    `\
`#>  [5] digest_0.6.39      magrittr_2.0.5     evaluate_1.0.5     grid_4.6.1        `\
`#>  [9] RColorBrewer_1.1-3 fastmap_1.2.0      jsonlite_2.0.0     Matrix_1.7-6      `\
`#> [13] purrr_1.2.2        scales_1.4.0       tweenr_2.0.3       textshaping_1.0.5 `\
`#> [17] jquerylib_0.1.4    cli_3.6.6          rlang_1.3.0        polyclip_1.10-7   `\
`#> [21] withr_3.0.3        cachem_1.1.0       yaml_2.3.12        otel_0.2.0        `\
`#> [25] tools_4.6.1        forcats_1.0.1      vctrs_0.7.3        R6_2.6.1          `\
`#> [29] lifecycle_1.0.5    fs_2.1.0           htmlwidgets_1.6.4  MASS_7.3-66       `\
`#> [33] pkgconfig_2.0.3    desc_1.4.3         pkgdown_2.2.1      pillar_1.11.1     `\
`#> [37] bslib_0.12.0       gtable_0.3.6       glue_1.8.1         xfun_0.62         `\
`#> [41] tibble_3.3.1       tidyselect_1.2.1   knitr_1.52         farver_2.1.2      `\
`#> [45] htmltools_0.5.9    igraph_2.3.4       labeling_0.4.3     rmarkdown_2.32    `\
`#> [49] compiler_4.6.1     S7_0.2.2`
