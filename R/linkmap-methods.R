#' Methods for linkmap S7 container class
#' @name linkmap-methods
#' @rdname linkmap-methods
#' @examples
#' # Setup
#' a2b <- data.frame(
#'   a = sample(letters[seq(3)], 10, replace = TRUE),
#'   b = sample(LETTERS[seq(3)], 10, replace = TRUE)
#' )
#'
#' # Create linkmap
#' x <- linkmap(a2b)
#'
#' # Basic properties
#' dim(x)
#' dimnames(x)
#'
#' print(x)
#'
#' # Factor-like properties
#' levels(x)
#' nlevels(x)
#'
#' @param x,object `linkmap` on which the method should be applied.
#' @returns A `linkmap`
NULL

S7::method(print, linkmap) <- function(x, n = 10L, show_metadata = FALSE, ...) {
  nr <- NROW(x)
  nrn <- nr - n
  cat("A ", paste(class(x), collapse = " "), ": ", nr, " rows.\n", sep = "")
  # Factor columns
  if (n < nr) {
    print(`class<-`(S7::S7_data(x[seq_len(n)]), "data.frame"))
    cat(" +", nrn, "more rows. Use `print(n = ...)` to see more rows.\n")
  } else {
    print(`class<-`(S7::S7_data(x), "data.frame"))
  }

  # Levels
  cat("\n@ levels:  ", length(levels(x)), "variables: \n")
  .print_levels(x)

  # Metadata
  if (prod(dim(m <- x@metadata))) {
    if(show_metadata) {
      cat("\n@ metadata:", NCOL(m), "variables: \n")
      # Dodge data.frame str header by forcing str.default:
      str(`class<-`(m, "default"), give.attr = FALSE, give.length = FALSE)
    } else {
      cat("\n and ", NCOL(m), " metadata variables.")
    }
  }
}


#' @param use.names `Boolean scalar` Should names be provided.
#'     (Default: `TRUE`)
#' @noRd
#'
S7::method(nlevels, linkmap) <- function(x, use.names = TRUE) lengths(
  levels(x), use.names
)

S7::method(levels, linkmap) <- function(x) x@levels

#' @export
#'
`levels<-.multifactor::linkmap` <- function(x, value) {
  x@levels <- value
  return(x)
}

#' @export
#'
`unique.multifactor::linkmap` <- function(x, incomparables = FALSE, ...) {
  if (!isFALSE(incomparables))
    .NotYetUsed("incomparables != FALSE")
  x[!duplicated(x)]
}

#' @importFrom rlang check_dots_empty0 is_missing
#' @export
#'
`[.multifactor::linkmap` <- function(x, i, ...) {
  rlang::check_dots_empty0(...)
  if (!rlang::is_missing(i)) {
    metadata <- x@metadata
    metadata <- `[.data.frame`(metadata, i, , drop = FALSE)

    x <- `class<-`(S7::S7_data(x), "data.frame")
    x <- `[.data.frame`(x, i, , drop = FALSE)

    x <- linkmap(x, metadata)
  }
  return(x)
}


#' @title Convert a linkmap to a sparse matrix.
#' Convert a linkmap to a sparse matrix object from the `Matrix` package.
#' @name as.matrix.linkmap
#' @param x a `linkmap` object.
#' @param terms id of cols in their desired order. `c(rows, cols)`.
#' @param dims length-2 integer vector of matrix dimensions.
#'     Default: `colnames(x)`
#' @param dimnames list of dimnames. (Default: `levels(x)`).
#' @param value_id Name or index of column in metadata to use as matrix values.
#' @param force_pattern `Boolean`. Whether to ignore value and return a sparse
#'     pattern matrix. (Default: FALSE)
#' @param ... additional arguments. Not used.
#' @importFrom Matrix sparseMatrix
#' @returns a sparse biadjacency `Matrix` with
#' @export
#' @seealso [Matrix::sparseMatrix()]
#' @examples
#' x <- random_linkmap()
#' as.matrix(x)
#'
`as.matrix.multifactor::linkmap` <- function(x, terms = colnames(x),
                                             dims = nlevels(x)[terms], dimnames = levels(x)[terms],
                                             value_id = NULL, force_pattern = is.null(value_id),
                                             ...) if (force_pattern) {
  Matrix::sparseMatrix(
    i = x[[terms[1L]]], j = x[[terms[2L]]],
    dims = dims, dimnames = dimnames, ...
  )
} else {
  if (!length(value_id)) value_id <- 1L
  value <- x@metadata[[value_id]]
  Matrix::sparseMatrix(
    i = x[[terms[1L]]], j = x[[terms[2L]]], x = value,
    dims = dims, dimnames = dimnames, ...
  )
}


#' @title Convert a linkmap to a data.frame
#' Convert a linkmap back to a regular data.frame. Metadata is included.
#' @name as.data.frame.linkmap
#' @param x a `linkmap` object.
#' @param row.names,optional,... For compatibility, not currently used.
#' @importFrom S7 S7_data
#' @returns a `data.frame`
#' @examples
#' x <- random_linkmap()
#' as.data.frame(x)
#' @export
#'
`as.data.frame.multifactor::linkmap` <- function(
  x, row.names, optional, ...
) cbind(S7::S7_data(x), x@metadata)


##### linkmap utils

.colnames2name <- function(x) paste(x, collapse = "2")

.linkmap2name <- function(x) paste(names(x), collapse = "2")
