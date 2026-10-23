# Convert a linkmap to igraph

Extract relational information from linkmap and return an igraph object.
Calls
[`igraph::graph_from_biadjacency_matrix`](https://r.igraph.org/reference/graph_from_biadjacency_matrix.html)
under the hood.

## Usage

``` r
# S3 method for class '`multifactor::linkmap`'
as.igraph(x, directed = FALSE, ...)
```

## Arguments

- x:

  a `multifactor`

- directed:

  See
  [`?igraph::graph_from_biadjacency_matrix`](https://r.igraph.org/reference/graph_from_biadjacency_matrix.html)

- ...:

  Additional arguments passed to
  [`igraph::graph_from_biadjacency_matrix`](https://r.igraph.org/reference/graph_from_biadjacency_matrix.html).

## Value

an `igraph` object.

## Details

If a `linkmap` contains metadata, this can be found back as edge
attributes in the returned graph (see
[`igraph::edge_attr()`](https://r.igraph.org/reference/edge_attr.html))

## Examples

``` r
x <- random_linkmap()

# Make igraph object:
igraph::as.igraph(x)
#> IGRAPH e24016c UN-B 52 338 -- 
#> + attr: type (v/l), name (v/c)
#> + edges from e24016c (vertex names):
#>   [1] d--A e--A h--A j--A k--A l--A m--A n--A o--A p--A q--A s--A t--A v--A w--A
#>  [16] z--A d--B h--B k--B l--B m--B s--B t--B w--B a--B c--B f--B i--B r--B x--B
#>  [31] y--B e--C h--C k--C p--C q--C s--C z--C c--C f--C i--C u--C d--D h--D j--D
#>  [46] k--D l--D o--D p--D s--D t--D v--D z--D c--D f--D r--D x--D y--D u--D d--E
#>  [61] e--E h--E j--E k--E l--E n--E q--E s--E t--E z--E a--E c--E f--E y--E b--E
#>  [76] d--F e--F h--F k--F l--F t--F v--F z--F f--F i--F r--F x--F u--F b--F g--F
#>  [91] e--G j--G n--G o--G t--G v--G a--G c--G i--G r--G x--G y--G u--G g--G d--H
#> [106] k--H l--H n--H o--H p--H q--H s--H t--H w--H z--H f--H i--H r--H x--H y--H
#> + ... omitted several edges
```
