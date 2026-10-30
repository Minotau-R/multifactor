# multifactor

## Overview

`multifactor` aims to provide a consistent toolkit to incorporate
relational data into data-analytical tools and methods. In practice, we
expect `multifactor` to be used in combination with additional packages
that extend it. For instance, see
[ariadne](https://github.com/minotau-R/ariadne) and
[anansi](https://github.com/thomazbastiaanssen/anansi), two such
packages that make use of `multifactor` to link and convert across
biological database IDs and perform multi-omics integration analysis,
respectively.

## Get started using multifactor

### Installation instructions

Get the latest stable `R` release from
[CRAN](http://cran.r-project.org/). Then install the released version of
`multifactor`:

\
[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"multifactor"``)`

Or install the development version from this repository:

\
[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"remotes"``)`\
`remotes``::`[`install_github`](https://remotes.r-lib.org/reference/install_github.html)`(``"minotau-R/multifactor"``)`

### Setup

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`multifactor`](https://minotau-r.github.io/multifactor/)`)`\
\
`# Wrangling`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`\
\
`# Plotting`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`systemfonts`](https://github.com/r-lib/systemfonts)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ragg`](https://ragg.r-lib.org)`)`\
\
`# Load demo data`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``2612``)`\
`tp`` ``<-`` `[`trade_posts`](https://minotau-r.github.io/multifactor/reference/random_multifactor.md)`(``)`

## multifactor and linkmap objects

### linkmap

The basic object in the `multifactor` package is the `linkmap`, which
contains relational information across two types of features. This
format is sometimes referred to as an [edge
list](https://en.wikipedia.org/wiki/Edge_list). Under a thin layer of
S7, the `linkmap` object is a `data.frame` where the first two columns
indicate which feature IDs that are considered linked. Optional
additional columns are considered metadata.

Let’s use an example data set to take a closer look at `linkmap`. The
[`trade_posts()`](https://minotau-r.github.io/multifactor/reference/random_multifactor.md)
function generates data about fictional trade posts, where one type of
good is traded for another. In this particular case, types of books are
traded for types of furniture.

\
`linkmap`` ``<-`` ``tp``[[``1``]``]`\
`linkmap`\
`#> A multifactor::linkmap data.frame S7_object: 9 rows.`\
`#>        books furniture`\
`#> 1   red book     couch`\
`#> 2 green book   cabinet`\
`#> 3 plain book   cabinet`\
`#> 4  blue book  wastebin`\
`#> 5 plain book  wastebin`\
`#> 6  blue book       box`\
`#> 7 plain book       box`\
`#> 8 fancy book      door`\
`#> 9  blue book      door`\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ books     : 6 Levels: fancy book ... plain book `\
`#>  $ furniture : 6 Levels: couch ... door `\
`#> `\
`#> @ metadata: 2 variables: `\
`#> List of 2`\
`#>  $ books_emoji    : chr  "📕" "📗" "📓" "📘" ...`\
`#>  $ furniture_emoji: chr  "🛋" "🗄" "🗄" "🗑" ...`

The two types of goods are captured by the two columns, with column
names representing the *types* of good and rows representing which
specific *type-pairs* are traded at that trade post, or, more generally,
are linked in that `linkmap`.

\
[`levels`](https://rdrr.io/r/base/levels.html)`(``linkmap``)`\
`#> $books`\
`#> [1] "fancy book"  "green book"  "red book"    "blue book"   "orange book"`\
`#> [6] "plain book" `\
`#> `\
`#> $furniture`\
`#> [1] "couch"    "cabinet"  "wastebin" "bed"      "box"      "door"`

Notice that `linkmap` is two `factor` columns in a trench coat. We can
inspect the levels as usual.

We can see that we have several of these types of trade posts in our
data set. However, we also notice that the column names - the types of
goods - can differ.

\
[`length`](https://rdrr.io/r/base/length.html)`(``tp``)`\
`#> [1] 6`\
`tp``[[``2``]``]`\
`#> A multifactor::linkmap data.frame S7_object: 9 rows.`\
`#>   clothing furniture`\
`#> 1    scarf     couch`\
`#> 2    scarf   cabinet`\
`#> 3   gloves  wastebin`\
`#> 4      hat  wastebin`\
`#> 5    scarf  wastebin`\
`#> 6    dress       bed`\
`#> 7  t-shirt       box`\
`#> 8    scarf       box`\
`#> 9      hat      door`\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ clothing  : 6 Levels: t-shirt ... scarf `\
`#>  $ furniture : 6 Levels: couch ... door `\
`#> `\
`#> @ metadata: 2 variables: `\
`#> List of 2`\
`#>  $ clothing_emoji : chr  "🧣" "🧣" "🧤" "🎩" ...`\
`#>  $ furniture_emoji: chr  "🛋" "🗄" "🗑" "🗑" ...`

#### Visual representation of the linkmaps in our data set.

![](images/plot-linkmap.png)

### multifactor

The `multifactor` is in essence a collection of `linkmap`s. Where
`linkmap`s contain relational information across two data types,
`multifactor`s are a representation of the relational graph formed by
combining those `linkmaps`. The full object `tp`, which contains the
`linkmaps` we just investigated, is in fact a `multifactor` object:

\
`tp`\
`#> A multifactor::multifactor list S7_object,`\
`#>     6 feature types across 6 linkmaps.`\
`#> `\
`#>                     books furniture clothing instruments fruit marbles`\
`#> books2furniture         5         5        .           .     .       .`\
`#> clothing2furniture      .         6        5           .     .       .`\
`#> books2instruments       5         .        .           6     .       .`\
`#> fruit2instruments       .         .        .           6     5       .`\
`#> furniture2marbles       .         5        .           .     .       6`\
`#> instruments2marbles     .         .        .           5     .       4`\
`#> `\
`#> Values represent unique feature names in that linkmap.`\
`#> `\
`#> @ levels:`\
`#>  $ books       : 6 Levels: fancy book ... plain book `\
`#>  $ furniture   : 6 Levels: couch ... door `\
`#>  $ clothing    : 6 Levels: t-shirt ... scarf `\
`#>  $ instruments : 6 Levels: trumpet ... saxophone `\
`#>  $ fruit       : 6 Levels: apples ... grapes `\
`#>  $ marbles     : 6 Levels: red marble ... sparkly marble`

Notice that a `multifactor` summarizes information across the component
`linkmaps` in several ways. First, The matrix shows the types of goods
as columns and the component `linkmaps` that contain this information as
rows. The numbers in the matrix then show the number of unique types of
that type of good in that particular `linkmap` - and that are therefore
linked to the second feature in the `linkmap`.

For instance, in the top-left corner of the matrix, we can see that the
first `linkmap` links books and furniture and is aptly named
`books2furniture`. Notice that five unique types of books as well as
five types of furniture are mentioned in `books2furniture`.

Though `multifactor` is a list of `linkmap`s under the hood, we can also
interact with its matrix representation, as well as access the component
levels:

\
[`dim`](https://rdrr.io/r/base/dim.html)`(``tp``)`\
`#> [1] 6 6`\
[`dimnames`](https://rdrr.io/r/base/dimnames.html)`(``tp``)`\
`#> [[1]]`\
`#> [1] "books2furniture"     "clothing2furniture"  "books2instruments"  `\
`#> [4] "fruit2instruments"   "furniture2marbles"   "instruments2marbles"`\
`#> `\
`#> [[2]]`\
`#> [1] "books"       "furniture"   "clothing"    "instruments" "fruit"      `\
`#> [6] "marbles"`\
[`levels`](https://rdrr.io/r/base/levels.html)`(``tp``)`\
`#> $books`\
`#> [1] "fancy book"  "green book"  "red book"    "blue book"   "orange book"`\
`#> [6] "plain book" `\
`#> `\
`#> $clothing`\
`#> [1] "t-shirt" "dress"   "socks"   "gloves"  "hat"     "scarf"  `\
`#> `\
`#> $fruit`\
`#> [1] "apples"   "pears"    "cherries" "oranges"  "melons"   "grapes"  `\
`#> `\
`#> $furniture`\
`#> [1] "couch"    "cabinet"  "wastebin" "bed"      "box"      "door"    `\
`#> `\
`#> $instruments`\
`#> [1] "trumpet"   "guitar"    "drum"      "keyboard"  "fiddle"    "saxophone"`\
`#> `\
`#> $marbles`\
`#> [1] "red marble"     "white marble"   "black marble"   "blue marble"   `\
`#> [5] "8 marble"       "sparkly marble"`\
[`nlevels`](https://minotau-r.github.io/multifactor/reference/nlevels.md)`(``tp``)`\
`#>       books    clothing       fruit   furniture instruments     marbles `\
`#>           6           6           6           6           6           6`

Note that levels of the same type are automatically unified across all
component linkmaps with that type of level.

#### Overview of multifactor classes and terms.

![](images/multifactor-anatomy.png)

## weave() a path

Going back to our trading post example, let’s say we’d want to get some
new hats, but we only have fruit. While both fruit and clothing are
available in our data set, there aren’t any trade post that deals in
that particular pair of goods. However, we could imagine trading our
fruit for clothing in steps: We can trade our fruit for a different
good, which we trade for another one, until we reach a good that we can
trade for clothing. The
[`weave()`](https://minotau-r.github.io/multifactor/reference/weave-generic.md)
function does exactly this:

\
`fruit2clothing`` ``<-`` `[`weave`](https://minotau-r.github.io/multifactor/reference/weave-generic.md)`(``tp``, ``fruit`` ``~`` ``clothing``)`\
`fruit2clothing`\
`#> A multifactor::linkmap data.frame S7_object: 18 rows.`\
`#>      fruit clothing`\
`#> 1   apples  t-shirt`\
`#> 2    pears  t-shirt`\
`#> 3   apples   gloves`\
`#> 4    pears   gloves`\
`#> 5   apples      hat`\
`#> 6    pears      hat`\
`#> 7   apples    scarf`\
`#> 8    pears    scarf`\
`#> 9  oranges    scarf`\
`#> 10  melons    scarf`\
`` #>  + 8 more rows. Use `print(n = ...)` to see more rows. ``\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ fruit    : 6 Levels: apples ... grapes `\
`#>  $ clothing : 6 Levels: t-shirt ... scarf`

We receive a new `linkmap` containing all fruits that could be traded
for clothing.

### Selecting a path

We can use
[`select_path()`](https://minotau-r.github.io/multifactor/reference/select_path-generic.md)
to find the types of traded goods in order, or more generally, the paths
that were traversed. If several paths exist, all will be traversed and
included into one `linkmap`.

\
[`select_path`](https://minotau-r.github.io/multifactor/reference/select_path-generic.md)`(``tp``, ``fruit`` ``~`` ``clothing``)`\
`#> A multifactor::path_frame S7_object.`\
`` #>   A path from `fruit` to `clothing` with 2 sub-paths: ``\
`#> fruit ~ instruments ~ books ~ furniture ~ clothing`\
`#> `\
`#>          from          to cov_operator cov_value stack components`\
`#> 1       fruit instruments           >=         0 FALSE          1`\
`#> 2 instruments       books           >=         0 FALSE          1`\
`#> 3       books   furniture           >=         0 FALSE          1`\
`#> 4   furniture    clothing           >=         0 FALSE          1`\
`#> 5       fruit instruments           >=         0 FALSE          2`\
`#> 6 instruments     marbles           >=         0 FALSE          2`\
`#> 7     marbles   furniture           >=         0 FALSE          2`\
`#> 8   furniture    clothing           >=         0 FALSE          2`

## Utilities

### Compatibility with `igraph` and `Matrix`

`multifactor` relies heavily on the excellent
[`igraph`](https://r.igraph.org/) and
[`Matrix`](https://matrix.r-forge.r-project.org/) packages, particularly
for path finding and sparse matrix representation.

#### Convert `multifactor` main graph representation to `igraph` object

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`igraph`](https://r.igraph.org/)`)`\
`#> `\
`#> Attaching package: 'igraph'`\
`#> The following objects are masked from 'package:dplyr':`\
`#> `\
`#>     as_data_frame, groups, union`\
`#> The following objects are masked from 'package:stats':`\
`#> `\
`#>     decompose, spectrum`\
`#> The following object is masked from 'package:base':`\
`#> `\
`#>     union`\
`# Convert to an igraph object`\
`g`` ``<-`` `[`as.igraph`](https://r.igraph.org/reference/as.igraph.html)`(``tp``)`\
`g`\
`#> IGRAPH a3e1825 UN-- 6 6 -- `\
`#> + attr: name (v/c), name (e/c), instruments_emoji (e/n), marbles_emoji`\
`#> | (e/n), furniture_emoji (e/n), books_emoji (e/n), clothing_emoji`\
`#> | (e/n), fruit_emoji (e/n)`\
`#> + edges from a3e1825 (vertex names):`\
`#> [1] books      --furniture   clothing   --furniture   books      --instruments`\
`#> [4] fruit      --instruments furniture  --marbles     instruments--marbles`\
`# Plot graph across data types`\
[`plot`](https://rdrr.io/r/graphics/plot.default.html)`(``g``)`

![](multifactor_files/figure-html/igraph-multifactor-sp-1.png)

#### Convert `linkmap` relational information to `igraph` object

\
`# Convert to an igraph object`\
`lg`` ``<-`` `[`as.igraph`](https://r.igraph.org/reference/as.igraph.html)`(``fruit2clothing``)`\
`lg`\
`#> IGRAPH b91ce17 UN-B 12 18 -- `\
`#> + attr: type (v/l), name (v/c)`\
`#> + edges from b91ce17 (vertex names):`\
`#>  [1] apples --t-shirt pears  --t-shirt apples --dress   oranges--dress  `\
`#>  [5] melons --dress   grapes --dress   apples --gloves  pears  --gloves `\
`#>  [9] apples --hat     pears  --hat     oranges--hat     melons --hat    `\
`#> [13] grapes --hat     apples --scarf   pears  --scarf   oranges--scarf  `\
`#> [17] melons --scarf   grapes --scarf`\
`# Same information as the linkmap:`\
[`plot`](https://rdrr.io/r/graphics/plot.default.html)`(``lg``)`

![](multifactor_files/figure-html/igraph-linkmap-sp-1.png)

#### Convert `linkmap` linkage information to sparse adjacency `Matrix`

\
`# Convert to an igraph object`\
`m`` ``<-`` `[`as.matrix`](https://rdrr.io/r/base/matrix.html)`(``fruit2clothing``)`\
`m`\
`#> 6 x 6 sparse Matrix of class "ngCMatrix"`\
`#>           clothing`\
`#> fruit      t-shirt dress socks gloves hat scarf`\
`#>   apples         |     |     .      |   |     |`\
`#>   pears          |     .     .      |   |     |`\
`#>   cherries       .     .     .      .   .     .`\
`#>   oranges        .     |     .      .   |     |`\
`#>   melons         .     |     .      .   |     |`\
`#>   grapes         .     |     .      .   |     |`

### Data wrangling

`multifactor` also provides some utility functions for data wrangling on
tables with features (rows) of the appropriate type.

\
`# Generate small example table`\
`generate_sample`` ``<-`` ``function``(``n``)`` `[`rbinom`](https://rdrr.io/r/stats/Binomial.html)`(``n``, `[`rbinom`](https://rdrr.io/r/stats/Binomial.html)`(``n``, ``100``, `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n``)``)``, `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n``)``)`\
`n`` ``<-`` `[`nlevels`](https://minotau-r.github.io/multifactor/reference/nlevels.md)`(``tp``)``[[``"clothing"``]``]`\
\
`clothing_table`` ``<-`` `[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(`[`replicate`](https://rdrr.io/r/base/lapply.html)`(``10``, ``generate_sample``(``n``)``)``)`\
[`rownames`](https://rdrr.io/r/base/colnames.html)`(``clothing_table``)`` ``<-`` `[`levels`](https://rdrr.io/r/base/levels.html)`(``tp``)``$``clothing`\
\
`clothing_table`\
`#>         V1 V2 V3 V4 V5 V6 V7 V8 V9 V10`\
`#> t-shirt 14  8 34 72 47  4 32 50  0   5`\
`#> dress   16 11 34 40 35 63  2 28  0  42`\
`#> socks   20 24 20 50  2  0 19  5 17  46`\
`#> gloves   0 34 10  2 21 30  0  3 13  16`\
`#> hat      0 61  0  4  3  0  7 20 38  21`\
`#> scarf    4 80 47 72 29 55  4  4 16  25`

#### weave_apply

`weave_apply` allows us to run arbitrary code on subsets of a table,
based on groupings on the left hand of the formula:

\
[`weave_apply`](https://minotau-r.github.io/multifactor/reference/weave_apply-generic.md)`(`\
`  .x ``=`` ``tp``, .path ``=`` ``fruit`` ``~`` ``clothing``,`\
`  .data ``=`` ``clothing_table``, .fun ``=`` ``as.data.frame`\
`)`\
`#> $apples`\
`#>         V1 V2 V3 V4 V5 V6 V7 V8 V9 V10`\
`#> dress   16 11 34 40 35 63  2 28  0  42`\
`#> hat      0 61  0  4  3  0  7 20 38  21`\
`#> scarf    4 80 47 72 29 55  4  4 16  25`\
`#> t-shirt 14  8 34 72 47  4 32 50  0   5`\
`#> gloves   0 34 10  2 21 30  0  3 13  16`\
`#> `\
`#> $pears`\
`#>         V1 V2 V3 V4 V5 V6 V7 V8 V9 V10`\
`#> t-shirt 14  8 34 72 47  4 32 50  0   5`\
`#> gloves   0 34 10  2 21 30  0  3 13  16`\
`#> hat      0 61  0  4  3  0  7 20 38  21`\
`#> scarf    4 80 47 72 29 55  4  4 16  25`\
`#> `\
`#> $oranges`\
`#>       V1 V2 V3 V4 V5 V6 V7 V8 V9 V10`\
`#> dress 16 11 34 40 35 63  2 28  0  42`\
`#> hat    0 61  0  4  3  0  7 20 38  21`\
`#> scarf  4 80 47 72 29 55  4  4 16  25`\
`#> `\
`#> $melons`\
`#>       V1 V2 V3 V4 V5 V6 V7 V8 V9 V10`\
`#> dress 16 11 34 40 35 63  2 28  0  42`\
`#> hat    0 61  0  4  3  0  7 20 38  21`\
`#> scarf  4 80 47 72 29 55  4  4 16  25`\
`#> `\
`#> $grapes`\
`#>       V1 V2 V3 V4 V5 V6 V7 V8 V9 V10`\
`#> dress 16 11 34 40 35 63  2 28  0  42`\
`#> hat    0 61  0  4  3  0  7 20 38  21`\
`#> scarf  4 80 47 72 29 55  4  4 16  25`\
\
`# More complex example:`\
`# For all subgroups of clothing corresponding to one particular fruit, if that`\
`# group has more than two rows (types of clothing), fit a statistical model.`\
`#`\
[`weave_apply`](https://minotau-r.github.io/multifactor/reference/weave_apply-generic.md)`(`\
`  ``tp``, ``fruit`` ``~`` ``clothing``, ``clothing_table``, ``function``(``x``)`` ``{`\
`    ``if`` ``(`[`NROW`](https://rdrr.io/r/base/nrow.html)`(``x``)`` ``<=`` ``2``)`` `[`return`](https://rdrr.io/r/base/function.html)`(``NULL``)`\
`    ``# else:`\
`    `[`summary`](https://rdrr.io/r/base/summary.html)`(`[`lm`](https://rdrr.io/r/stats/lm.html)`(``V1`` ``~`` ``V2``, data ``=`` ``x``)``)`\
`  ``}`\
`)`\
`#> $apples`\
`#> `\
`#> Call:`\
`#> lm(formula = V1 ~ V2, data = x)`\
`#> `\
`#> Residuals:`\
`#>   dress     hat   scarf t-shirt  gloves `\
`#>   4.175  -2.787   4.647   1.633  -7.668 `\
`#> `\
`#> Coefficients:`\
`#>             Estimate Std. Error t value Pr(>|t|)  `\
`#> (Intercept) 13.81295    4.58505   3.013   0.0571 .`\
`#> V2          -0.18075    0.09576  -1.887   0.1555  `\
`#> ---`\
`#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1`\
`#> `\
`#> Residual standard error: 6.007 on 3 degrees of freedom`\
`#> Multiple R-squared:  0.5428, Adjusted R-squared:  0.3905 `\
`#> F-statistic: 3.562 on 1 and 3 DF,  p-value: 0.1555`\
`#> `\
`#> `\
`#> $pears`\
`#> `\
`#> Call:`\
`#> lm(formula = V1 ~ V2, data = x)`\
`#> `\
`#> Residuals:`\
`#> t-shirt  gloves     hat   scarf `\
`#>   4.522  -6.050  -2.489   4.017 `\
`#> `\
`#> Coefficients:`\
`#>             Estimate Std. Error t value Pr(>|t|)`\
`#> (Intercept)  10.5332     6.1564   1.711    0.229`\
`#> V2           -0.1319     0.1156  -1.141    0.372`\
`#> `\
`#> Residual standard error: 6.3 on 2 degrees of freedom`\
`#> Multiple R-squared:  0.3941, Adjusted R-squared:  0.09117 `\
`#> F-statistic: 1.301 on 1 and 2 DF,  p-value: 0.3722`\
`#> `\
`#> `\
`#> $oranges`\
`#> `\
`#> Call:`\
`#> lm(formula = V1 ~ V2, data = x)`\
`#> `\
`#> Residuals:`\
`#>  dress    hat  scarf `\
`#>  1.256 -4.563  3.306 `\
`#> `\
`#> Coefficients:`\
`#>             Estimate Std. Error t value Pr(>|t|)`\
`#> (Intercept)  16.9835     6.6920   2.538    0.239`\
`#> V2           -0.2036     0.1145  -1.778    0.326`\
`#> `\
`#> Residual standard error: 5.773 on 1 degrees of freedom`\
`#> Multiple R-squared:  0.7597, Adjusted R-squared:  0.5193 `\
`#> F-statistic: 3.161 on 1 and 1 DF,  p-value: 0.3262`\
`#> `\
`#> `\
`#> $melons`\
`#> `\
`#> Call:`\
`#> lm(formula = V1 ~ V2, data = x)`\
`#> `\
`#> Residuals:`\
`#>  dress    hat  scarf `\
`#>  1.256 -4.563  3.306 `\
`#> `\
`#> Coefficients:`\
`#>             Estimate Std. Error t value Pr(>|t|)`\
`#> (Intercept)  16.9835     6.6920   2.538    0.239`\
`#> V2           -0.2036     0.1145  -1.778    0.326`\
`#> `\
`#> Residual standard error: 5.773 on 1 degrees of freedom`\
`#> Multiple R-squared:  0.7597, Adjusted R-squared:  0.5193 `\
`#> F-statistic: 3.161 on 1 and 1 DF,  p-value: 0.3262`\
`#> `\
`#> `\
`#> $grapes`\
`#> `\
`#> Call:`\
`#> lm(formula = V1 ~ V2, data = x)`\
`#> `\
`#> Residuals:`\
`#>  dress    hat  scarf `\
`#>  1.256 -4.563  3.306 `\
`#> `\
`#> Coefficients:`\
`#>             Estimate Std. Error t value Pr(>|t|)`\
`#> (Intercept)  16.9835     6.6920   2.538    0.239`\
`#> V2           -0.2036     0.1145  -1.778    0.326`\
`#> `\
`#> Residual standard error: 5.773 on 1 degrees of freedom`\
`#> Multiple R-squared:  0.7597, Adjusted R-squared:  0.5193 `\
`#> F-statistic: 3.161 on 1 and 1 DF,  p-value: 0.3262`

#### Compatibility with the tidyverse: `weave_to_tbl`

For those who prefer to use `tidyverse`,
[`weave_to_tbl()`](https://minotau-r.github.io/multifactor/reference/weave_to_tbl.md)
returns a tidy wide-format table, ready to be grouped based on the first
two columns.

\
[`weave_to_tbl`](https://minotau-r.github.io/multifactor/reference/weave_to_tbl.md)`(``tp``, .path ``=`` ``fruit`` ``~`` ``clothing``, .data ``=`` ``clothing_table``)`\
`#>      fruit clothing V1 V2 V3 V4 V5 V6 V7 V8 V9 V10`\
`#> 1   apples    dress 16 11 34 40 35 63  2 28  0  42`\
`#> 2  oranges    dress 16 11 34 40 35 63  2 28  0  42`\
`#> 3   melons    dress 16 11 34 40 35 63  2 28  0  42`\
`#> 4   grapes    dress 16 11 34 40 35 63  2 28  0  42`\
`#> 5   apples      hat  0 61  0  4  3  0  7 20 38  21`\
`#> 6  oranges      hat  0 61  0  4  3  0  7 20 38  21`\
`#> 7   melons      hat  0 61  0  4  3  0  7 20 38  21`\
`#> 8   grapes      hat  0 61  0  4  3  0  7 20 38  21`\
`#> 9   apples    scarf  4 80 47 72 29 55  4  4 16  25`\
`#> 10 oranges    scarf  4 80 47 72 29 55  4  4 16  25`\
`#> 11  grapes    scarf  4 80 47 72 29 55  4  4 16  25`\
`#> 12  apples  t-shirt 14  8 34 72 47  4 32 50  0   5`\
`#> 13   pears  t-shirt 14  8 34 72 47  4 32 50  0   5`\
`#> 14  apples   gloves  0 34 10  2 21 30  0  3 13  16`\
`#> 15   pears   gloves  0 34 10  2 21 30  0  3 13  16`\
`#> 16   pears      hat  0 61  0  4  3  0  7 20 38  21`\
`#> 17   pears    scarf  4 80 47 72 29 55  4  4 16  25`\
`#> 18  melons    scarf  4 80 47 72 29 55  4  4 16  25`

### Reading and parsing adjaceny list-formatted files

Relational data between two types (bipartite) is sometimes expressed as
a text file to be read row-wise. The first element of each row specifies
a level of the first type of data, whereas all following elements all
from the second type, indicate which levels it is connected to. These
files can be tricky to load and properly parse into R. The function
[`read_adjacency_list()`](https://minotau-r.github.io/multifactor/reference/read_adjacency_list.md)
allows these files to be read from file (or URL).

#### Example of adjacency list formatted data

We’ll format the `linkmap` from fruit to furniture that we generated
above.

\
`# Use igraph to deconstruct a graph into an adjacency list, coerce to characters`\
`adj`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(`[`as_adj_list`](https://r.igraph.org/reference/as_adj_list.html)`(`[`as.igraph`](https://r.igraph.org/reference/as.igraph.html)`(``fruit2clothing``)``)``, ``as_ids``)`\
`# Only keep the 'fruit' nodes that have more than one link for now`\
`adj`` ``<-`` ``adj``[`[`levels`](https://rdrr.io/r/base/levels.html)`(``fruit2clothing``)``$``fruit``]`\
`adj`` ``<-`` ``adj``[`[`lengths`](https://rdrr.io/r/base/lengths.html)`(``adj``)`` ``>`` ``0``]`\
`# collapse names to first elements of character vectors`\
`adj`` ``<-`` `[`mapply`](https://rdrr.io/r/base/mapply.html)`(``c``, `[`names`](https://rdrr.io/r/base/names.html)`(``adj``)``, ``adj``, USE.NAMES ``=`` ``FALSE``)`\
`adj`` ``<-`` `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``adj``, ``paste``, collapse ``=`` ``"\t"``, ``""``)`

If stored in a file in adjacency list format, it may look like this:

    pear\tdesk
    cherry\tchair\ttable\tdesk
    melon\tchair\ttable\tdesk 
    blueberry\tchair\tdesk

\
`# Create some temporary file to read from:`\
`temp`` ``<-`` `[`tempfile`](https://rdrr.io/r/base/tempfile.html)`(``)`\
`# fill the temp file with the adjacency list we just constructed`\
`t.con`` ``<-`` `[`file`](https://rdrr.io/r/base/connections.html)`(``temp``, ``"w"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``adj``, file ``=`` ``t.con``, sep ``=`` ``"\n"``)`\
[`close`](https://rdrr.io/r/base/connections.html)`(``t.con``)`\
\
`adj_data`` ``<-`` `[`read_adjacency_list`](https://minotau-r.github.io/multifactor/reference/read_adjacency_list.md)`(``temp``)`\
`adj_data`\
`#> A multifactor::linkmap data.frame S7_object: 18 rows.`\
`#>       id.x    id.y`\
`#> 1   apples t-shirt`\
`#> 2   apples   dress`\
`#> 3   apples  gloves`\
`#> 4   apples     hat`\
`#> 5   apples   scarf`\
`#> 6    pears t-shirt`\
`#> 7    pears  gloves`\
`#> 8    pears     hat`\
`#> 9    pears   scarf`\
`#> 10 oranges   dress`\
`` #>  + 8 more rows. Use `print(n = ...)` to see more rows. ``\
`#> `\
`#> @ levels:   2 variables: `\
`#>  $ id.x : 5 Levels: apples grapes ... pears `\
`#>  $ id.y : 5 Levels: dress gloves ... t-shirt`\
\
`# Notice that the unlinked data types are no longer in the graph.`\
[`plot`](https://rdrr.io/r/graphics/plot.default.html)`(`[`as.igraph`](https://r.igraph.org/reference/as.igraph.html)`(``adj_data``)``)`

![](multifactor_files/figure-html/read-adj-1.png)

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
`#> [1] igraph_2.3.4      ragg_1.5.2        systemfonts_1.3.2 ggplot2_4.0.3    `\
`#> [5] dplyr_1.2.1       multifactor_0.1.3`\
`#> `\
`#> loaded via a namespace (and not attached):`\
`#>  [1] Matrix_1.7-6       gtable_0.3.6       jsonlite_2.0.0     compiler_4.6.1    `\
`#>  [5] tidyselect_1.2.1   jquerylib_0.1.4    scales_1.4.0       textshaping_1.0.5 `\
`#>  [9] yaml_2.3.12        fastmap_1.2.0      lattice_0.23-1     R6_2.6.1          `\
`#> [13] generics_0.1.4     knitr_1.52         MASS_7.3-66        htmlwidgets_1.6.4 `\
`#> [17] forcats_1.0.1      polyclip_1.10-7    tibble_3.3.1       desc_1.4.3        `\
`#> [21] RColorBrewer_1.1-3 bslib_0.12.0       pillar_1.11.1      rlang_1.3.0       `\
`#> [25] cachem_1.1.0       xfun_0.62          fs_2.1.0           sass_0.4.10       `\
`#> [29] S7_0.2.2           otel_0.2.0         cli_3.6.6          tweenr_2.0.3      `\
`#> [33] withr_3.0.3        pkgdown_2.2.1      magrittr_2.0.5     digest_0.6.39     `\
`#> [37] grid_4.6.1         ggforce_0.5.0      lifecycle_1.0.5    vctrs_0.7.3       `\
`#> [41] evaluate_1.0.5     glue_1.8.1         farver_2.1.2       rmarkdown_2.32    `\
`#> [45] tools_4.6.1        pkgconfig_2.0.3    htmltools_0.5.9`
