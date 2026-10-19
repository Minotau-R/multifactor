# multifactor S7 container class

`multifactor` is an S7 class to organize and manage multiple sets of
factors, for instance when tracing or converting feature IDs across
databases. Methods for `multifactor` aim to follow `factor` behaviour.

## Usage

``` r
multifactor(x, levels = list())
```

## Arguments

- x:

  a `linkmap`, or named list of `linkmap` objects.

- levels:

  Optional. A `named list of character vectors`, to be used as levels.

## Value

a `multifactor` object.

## Details

The most straightforward way to construct a `multifactor` object is as a
named list of named data.frames. The columns of the data.frames indicate
the category of factor in that column.

A `multifactor` object presents itself similar to a `data.frame`, in the
sense that level types can be called as columns and individual
data.frame components can be called as rows. `multifactor` inherits from
`list`; Content can be accessed through regular list methods (e.g., `[`,
`[[`).

## Slots

- `levels`:

  `Named list of character vectors`. Accessed through `levels(x)`

- `map`:

  `(sparse) Matrix` specifying which elements contain which levels.

## See also

[`multifactor-methods()`](https://minotau-r.github.io/multifactor/reference/multifactor-methods.md)

[`linkmap()`](https://minotau-r.github.io/multifactor/reference/linkmap-class.md)

## Examples

``` r
# Generate some random linkage input
a2b <- data.frame(
  a = sample(letters[seq(3)], 10, replace = TRUE),
  b = sample(LETTERS[seq(3)], 10, replace = TRUE)
)
a2c <- data.frame(
  a = sample(letters[seq(3)], 10, replace = TRUE),
  c = sample(LETTERS[seq(3)], 10, replace = TRUE)
)
x <- multifactor(list(a2b, a2c))
```
