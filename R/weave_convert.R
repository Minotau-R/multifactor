#' Expand a table based on possibly overlapping group membership.
#' @name weave_convert
#' @description
#' Expand a table into a tidy table suitable for tidyverse-style operations.
#' @param x a `multifactor`.
#' @param .path either a `formula` or a `character vector`` of length 2 with the
#'     names of the desired combination of feature types.
#' @param .data `A table`. A `data.frame`, `matrix`, other object with rows and
#'     columns. Should have a `cbind` method.
#' @param .transform `An expression` detailing whether numerical values should
#'     be transformed in addition to being linked to other feature types.
#'     Leaving this at `NULL` indicates no transformation (Default).
#' @param .index `Character scalar` Column to look for feature IDs to link.
#'     Default: "row.names".
#' @returns An expanded table `x`, with an added first column containing
#'     subgroups.
#' @importFrom Matrix which
#' @examples
#' # Prepare data
#' set.seed(2612)
#' x <- trade_posts()
#'
#' # Generate small example feature table 'df'.
#' n <- nlevels(x)[["fruit"]]
#' df <- replicate(10, rbinom(n, rbinom(n, 100, runif(n)), runif(n)))
#'
#' # Ensure feature names correspond to the first (LHS) variable in the formula.
#' df <- as.data.frame(df, row.names = levels(x)$fruit)
#'
#' # Return a table with two feature type columns.
#' weave_convert(x, .path = fruit ~ clothing, .data = df)
#'
#' @export
#'
weave_convert <- function(
    x, .path, .data, .transform = NULL, .index = "row.names"
    ) {

  stopifnot("Transformations are not suported yet" = is.null(.transform))

  stopifnot("'x' must be a multifactor." = S7::S7_inherits(x, multifactor))
  pf <- .check_parse_path(x, .path, "weave_convert")

  lmp <- .weave_to_linkmap(x, pf, .data, .coverage_metrics)
  range_pf <- .pf_from_to(pf)
  out <- .weave_res_to_index(lmp, range_pf, .data, .i = .index)

  xcol <- if (.index == "row.names") row.names(.data) else .data[[.index]]
  subgroup <- data.frame(y = xcol[out[[2L]]], x = out[1L], check.rows = FALSE)
  colnames(subgroup) <- range_pf

  out <- data.frame(subgroup, .data[out[[2L]], ])
  row.names(out) <- NULL
  out
}


