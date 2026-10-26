# Convert a multifactor to igraph

Extract relational information from multifactor and return an igraph
object. Calls
[`igraph::graph_from_data_frame`](https://r.igraph.org/reference/graph_from_data_frame.html)
under the hood.

## Usage

``` r
# S3 method for class '`multifactor::multifactor`'
as.igraph(x, directed = FALSE, ...)
```

## Arguments

- x:

  a `multifactor`

- directed:

  See
  [`?igraph::graph_from_data_frame`](https://r.igraph.org/reference/graph_from_data_frame.html)

- ...:

  Additional arguments passed to
  [`igraph::graph_from_data_frame`](https://r.igraph.org/reference/graph_from_data_frame.html).

## Value

an `igraph` object.

## Examples

``` r
x <- random_multifactor()

# Make igraph object:
igraph::as.igraph(x)
#> IGRAPH 3316cf4 UN-- 6 5 -- 
#> + attr: name (v/c), name (e/c)
#> + edges from 3316cf4 (vertex names):
#> [1] a--b b--c c--d d--e e--f
```
