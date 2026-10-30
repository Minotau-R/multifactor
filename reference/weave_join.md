# Join linkmaps across a path

Generates a data.frame by combining all columns across linkmaps in a
path.

## Usage

``` r
weave_join(x, .path, metadata = FALSE, sort = TRUE, simplify = TRUE)
```

## Arguments

- x:

  a `multifactor`

- .path:

  Either a `formula` or a `character vector` of length 2 with the names
  of the desired combination of feature types.

- metadata:

  `Boolean` Whether to include all metadata within the linkmaps or just
  the factor columns (Default).

- sort:

  `Boolean`. Should the result be sorted by factor level?

- simplify:

  `Boolean`. Should the returned object be coerced to a `data.frame`, or
  should the raw list be returned?

## Value

a `data.frame`

## Examples

``` r
# Use the quick brown fox pangram dataset from the vignette
fox <- quickbrownfox()
weave_join(fox, letter ~ sentence)
#>    letter  word constituent                                    sentence
#> 1       a  lazy      object the quick brown fox jumps over the lazy dog
#> 2       b brown     subject the quick brown fox jumps over the lazy dog
#> 3       c quick     subject the quick brown fox jumps over the lazy dog
#> 4       d   dog      object the quick brown fox jumps over the lazy dog
#> 5       e  over   predicate the quick brown fox jumps over the lazy dog
#> 6       e   the      object the quick brown fox jumps over the lazy dog
#> 7       e   the     subject the quick brown fox jumps over the lazy dog
#> 8       f   fox     subject the quick brown fox jumps over the lazy dog
#> 9       g   dog      object the quick brown fox jumps over the lazy dog
#> 10      h   the      object the quick brown fox jumps over the lazy dog
#> 11      h   the     subject the quick brown fox jumps over the lazy dog
#> 12      i quick     subject the quick brown fox jumps over the lazy dog
#> 13      j jumps   predicate the quick brown fox jumps over the lazy dog
#> 14      k quick     subject the quick brown fox jumps over the lazy dog
#> 15      l  lazy      object the quick brown fox jumps over the lazy dog
#> 16      m jumps   predicate the quick brown fox jumps over the lazy dog
#> 17      n brown     subject the quick brown fox jumps over the lazy dog
#> 18      o brown     subject the quick brown fox jumps over the lazy dog
#> 19      o   dog      object the quick brown fox jumps over the lazy dog
#> 20      o   fox     subject the quick brown fox jumps over the lazy dog
#> 21      o  over   predicate the quick brown fox jumps over the lazy dog
#> 22      p jumps   predicate the quick brown fox jumps over the lazy dog
#> 23      q quick     subject the quick brown fox jumps over the lazy dog
#> 24      r brown     subject the quick brown fox jumps over the lazy dog
#> 25      r  over   predicate the quick brown fox jumps over the lazy dog
#> 26      s jumps   predicate the quick brown fox jumps over the lazy dog
#> 27      t   the      object the quick brown fox jumps over the lazy dog
#> 28      t   the     subject the quick brown fox jumps over the lazy dog
#> 29      u jumps   predicate the quick brown fox jumps over the lazy dog
#> 30      u quick     subject the quick brown fox jumps over the lazy dog
#> 31      v  over   predicate the quick brown fox jumps over the lazy dog
#> 32      w brown     subject the quick brown fox jumps over the lazy dog
#> 33      x   fox     subject the quick brown fox jumps over the lazy dog
#> 34      y  lazy      object the quick brown fox jumps over the lazy dog
#> 35      z  lazy      object the quick brown fox jumps over the lazy dog

# If there are multiple paths, the result is bound to a single data.frame
set.seed(2612)
tp <- trade_posts()
weave_join(tp, fruit ~ clothing)
#>    component   fruit instruments      books furniture        marbles clothing
#> 1          1  apples     trumpet green book   cabinet           <NA>    scarf
#> 2          1  apples      guitar   red book     couch           <NA>    scarf
#> 3          1  apples      guitar  blue book  wastebin           <NA>   gloves
#> 4          1  apples      guitar  blue book  wastebin           <NA>      hat
#> 5          1  apples      guitar  blue book  wastebin           <NA>    scarf
#> 6          1  apples      guitar  blue book       box           <NA>  t-shirt
#> 7          1  apples      guitar  blue book       box           <NA>    scarf
#> 8          1  apples      guitar  blue book      door           <NA>      hat
#> 9          1  apples        drum  blue book  wastebin           <NA>   gloves
#> 10         1  apples        drum  blue book  wastebin           <NA>      hat
#> 11         1  apples        drum  blue book  wastebin           <NA>    scarf
#> 12         1  apples        drum  blue book       box           <NA>  t-shirt
#> 13         1  apples        drum  blue book       box           <NA>    scarf
#> 14         1  apples        drum  blue book      door           <NA>      hat
#> 15         1  apples   saxophone plain book   cabinet           <NA>    scarf
#> 16         1  apples   saxophone plain book  wastebin           <NA>   gloves
#> 17         1  apples   saxophone plain book  wastebin           <NA>      hat
#> 18         1  apples   saxophone plain book  wastebin           <NA>    scarf
#> 19         1  apples   saxophone plain book       box           <NA>  t-shirt
#> 20         1  apples   saxophone plain book       box           <NA>    scarf
#> 21         1   pears      guitar   red book     couch           <NA>    scarf
#> 22         1   pears      guitar  blue book  wastebin           <NA>   gloves
#> 23         1   pears      guitar  blue book  wastebin           <NA>      hat
#> 24         1   pears      guitar  blue book  wastebin           <NA>    scarf
#> 25         1   pears      guitar  blue book       box           <NA>  t-shirt
#> 26         1   pears      guitar  blue book       box           <NA>    scarf
#> 27         1   pears      guitar  blue book      door           <NA>      hat
#> 28         1 oranges    keyboard green book   cabinet           <NA>    scarf
#> 29         1  melons      fiddle   red book     couch           <NA>    scarf
#> 30         1  grapes    keyboard green book   cabinet           <NA>    scarf
#> 31         1  grapes      fiddle   red book     couch           <NA>    scarf
#> 32         2  apples     trumpet       <NA>   cabinet   black marble    scarf
#> 33         2  apples     trumpet       <NA>   cabinet sparkly marble    scarf
#> 34         2  apples     trumpet       <NA>      door sparkly marble      hat
#> 35         2  apples        drum       <NA>       bed   white marble    dress
#> 36         2  apples        drum       <NA>      door   white marble      hat
#> 37         2  apples        drum       <NA>   cabinet    blue marble    scarf
#> 38         2  apples   saxophone       <NA>   cabinet   black marble    scarf
#> 39         2 oranges    keyboard       <NA>       bed   white marble    dress
#> 40         2 oranges    keyboard       <NA>      door   white marble      hat
#> 41         2 oranges    keyboard       <NA>   cabinet    blue marble    scarf
#> 42         2 oranges    keyboard       <NA>   cabinet sparkly marble    scarf
#> 43         2 oranges    keyboard       <NA>      door sparkly marble      hat
#> 44         2  melons      fiddle       <NA>       bed   white marble    dress
#> 45         2  melons      fiddle       <NA>      door   white marble      hat
#> 46         2  grapes    keyboard       <NA>       bed   white marble    dress
#> 47         2  grapes    keyboard       <NA>      door   white marble      hat
#> 48         2  grapes    keyboard       <NA>   cabinet    blue marble    scarf
#> 49         2  grapes    keyboard       <NA>   cabinet sparkly marble    scarf
#> 50         2  grapes    keyboard       <NA>      door sparkly marble      hat
#> 51         2  grapes      fiddle       <NA>       bed   white marble    dress
#> 52         2  grapes      fiddle       <NA>      door   white marble      hat

# Set 'simplify' to 'FALSE' to instead the unmerged data.frames in a list.
weave_join(tp, fruit ~ clothing, simplify = FALSE)
#> [[1]]
#>      fruit instruments      books furniture clothing
#> 1   apples     trumpet green book   cabinet    scarf
#> 2   apples      guitar   red book     couch    scarf
#> 3   apples      guitar  blue book  wastebin   gloves
#> 4   apples      guitar  blue book  wastebin      hat
#> 5   apples      guitar  blue book  wastebin    scarf
#> 6   apples      guitar  blue book       box  t-shirt
#> 7   apples      guitar  blue book       box    scarf
#> 8   apples      guitar  blue book      door      hat
#> 9   apples        drum  blue book  wastebin   gloves
#> 10  apples        drum  blue book  wastebin      hat
#> 11  apples        drum  blue book  wastebin    scarf
#> 12  apples        drum  blue book       box  t-shirt
#> 13  apples        drum  blue book       box    scarf
#> 14  apples        drum  blue book      door      hat
#> 15  apples   saxophone plain book   cabinet    scarf
#> 16  apples   saxophone plain book  wastebin   gloves
#> 17  apples   saxophone plain book  wastebin      hat
#> 18  apples   saxophone plain book  wastebin    scarf
#> 19  apples   saxophone plain book       box  t-shirt
#> 20  apples   saxophone plain book       box    scarf
#> 21   pears      guitar   red book     couch    scarf
#> 22   pears      guitar  blue book  wastebin   gloves
#> 23   pears      guitar  blue book  wastebin      hat
#> 24   pears      guitar  blue book  wastebin    scarf
#> 25   pears      guitar  blue book       box  t-shirt
#> 26   pears      guitar  blue book       box    scarf
#> 27   pears      guitar  blue book      door      hat
#> 28 oranges    keyboard green book   cabinet    scarf
#> 29  melons      fiddle   red book     couch    scarf
#> 30  grapes    keyboard green book   cabinet    scarf
#> 31  grapes      fiddle   red book     couch    scarf
#> 
#> [[2]]
#>      fruit instruments        marbles furniture clothing
#> 1   apples     trumpet   black marble   cabinet    scarf
#> 2   apples     trumpet sparkly marble   cabinet    scarf
#> 3   apples     trumpet sparkly marble      door      hat
#> 4   apples        drum   white marble       bed    dress
#> 5   apples        drum   white marble      door      hat
#> 6   apples        drum    blue marble   cabinet    scarf
#> 7   apples   saxophone   black marble   cabinet    scarf
#> 8  oranges    keyboard   white marble       bed    dress
#> 9  oranges    keyboard   white marble      door      hat
#> 10 oranges    keyboard    blue marble   cabinet    scarf
#> 11 oranges    keyboard sparkly marble   cabinet    scarf
#> 12 oranges    keyboard sparkly marble      door      hat
#> 13  melons      fiddle   white marble       bed    dress
#> 14  melons      fiddle   white marble      door      hat
#> 15  grapes    keyboard   white marble       bed    dress
#> 16  grapes    keyboard   white marble      door      hat
#> 17  grapes    keyboard    blue marble   cabinet    scarf
#> 18  grapes    keyboard sparkly marble   cabinet    scarf
#> 19  grapes    keyboard sparkly marble      door      hat
#> 20  grapes      fiddle   white marble       bed    dress
#> 21  grapes      fiddle   white marble      door      hat
#> 
```
