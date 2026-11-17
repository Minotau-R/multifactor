#' Weave a new linkmap from a multifactor
#' @name weave-methods
#' @rdname weave-methods
#' @description
#' Generates a new `linkmap` object by cross-referencing the elements of a
#'     given `multifactor`.
#' @param x a `multifactor`
#' @param .path Either a `formula` or a `character vector` of length 2 with the
#'     names of the desired combination of feature types.
#' @param out.format `Character scalar`. One of `'linkmap'`, `'matrix'`.
#' @param include,exclude,exact `Character vectors` Should feature types be
#'     included or excluded from the available paths? Exact allows for exact
#'     path definition.
#' @returns a `linkmap` or `sparse Matrix`.
#' @examples
#' # Generate a random multifactor
#' x <- random_multifactor()
#'
#' # Weave new b2c linkmap
#' weave(x, b ~ c)
#' weave(x, b ~ a, out.format = "matrix")
#'
NULL

S7::method(weave, multifactor) <- function(
  x, .path, out.format = c("linkmap", "matrix"),
  include = NULL, exclude = NULL, exact = NULL
) {
  out.format <- match.arg(out.format, c("linkmap", "matrix"))

  pf <- .check_parse_path(x, .path, "weave")
  res <- .weave_to_linkmap(x, pf, .data = NULL, metric = .coverage_metrics)

  if (out.format == "matrix") {
    res <- `as.matrix.multifactor::linkmap`(res)
  }

  res
}



.weave_full_path <- function(x, all_terms) {
  x <- .subset_by_path(x, all_terms)
  terms <- all_terms[c(1L, length(all_terms))]

  # Construct dictionary
  res <- .weave_to_dictionary_matrix(x, all_terms)

  # make a linkmap-shaped data.frame
  res <- .res_weave_matrix_to_linkmap(res, levels(x)[terms])

  return(res)
}

#' Generate dictionary Matrix from link input
#' @param link `multifactor`
#' @param all_terms `Character vector` of all path terms in sequence.
#'     `.term_seq(x, y, link)`
#' @importMethodsFrom Matrix %&%
#' @importFrom Matrix Matrix crossprod colSums t
#' @noRd
#'
.weave_to_dictionary_matrix <- function(link, all_terms) {
  term_list <- lapply(
    seq_len(length(all_terms) - 1L),
    FUN = function(x) all_terms[c(x, x + 1L)]
  )
  steps <- .step_seq(term_list, link@map)
  lv_len <- nlevels(link, use.names = TRUE)

  # Handle simple case of one link df first, return sparse matrix.
  if (length(steps) == 1L) {
    return(`as.matrix.multifactor::linkmap`(
      x = S7::S7_data(link)[[steps]],
      terms = all_terms,
      dims = lv_len[all_terms]
    ))
  }
  lv_list <- lapply(term_list, function(x) lv_len[x])
  # Otherwise, make a list of matrices to Reduce to final dictionary
  mat_list <- mapply(
    FUN = `as.matrix.multifactor::linkmap`,
    x = S7::S7_data(link)[steps],
    terms = term_list,
    dims = lv_list
  )
  Reduce(Matrix::`%&%`, mat_list)
}


#' @importFrom Matrix which
#'
.res_weave_matrix_to_linkmap <- function(res, lvs) {
  res <- as.data.frame.matrix(Matrix::which(res > 0L, arr.ind = TRUE))
  res[] <- mapply(FUN = function(x, y) {
    attr(x, "levels") <- y
    `class<-`(x, "factor")
  }, x = res, y = lvs, SIMPLIFY = FALSE)
  colnames(res) <- names(lvs)
  return(res)
}
