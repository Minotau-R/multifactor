#' Expand a table based on possibly overlapping group membership.
#' @name weave_convert
#' @description
#' Expand a table into a tidy table suitable for tidyverse-style operations.
#' @param x a `multifactor`.
#' @param .data `A table`. A `data.frame`, `matrix`, other object with rows and
#'     columns. Should have a `cbind` method.
#' @param .path either a `formula` or a `character vector`` of length 2 with the
#'     names of the desired combination of feature types.
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
#' # Ensure rownames correspond to the first (LHS) variable in the formula.
#' df <- as.data.frame(df, row.names = levels(x)$fruit)
#'
#' # Return a table with two feature type columns.
#' weave_convert(x, .path = fruit ~ clothing, .data = df)
#'
#' @export
#'
weave_convert <- function(x, .path, .data, .index = "row.names") {
  .valid_path_input(.path)
  pf <- as_path_frame(.path)
  .path_check_valid_weave_convert(pf)
  pf <- path_frame(.select_enframe_path(x, pf))

  full_path <- .pf_as_full_path_list(pf)

  lmp <- lapply(full_path, .weave_full_path, x = x)
  lmp <- do.call(rbind.data.frame, lmp)
  lmp <- linkmap(lmp)

  range_pf <- `range.multifactor::path_frame`(pf)

  out <- .weave_res_to_index(lmp, range_pf, .data, .i = .index)

  xcol <- if (.index == "row.names") row.names(.data) else .data[[.index]]

  subgroup <- data.frame(y = xcol[out[[2L]]], x = out[1L], check.rows = FALSE)

  colnames(subgroup) <- range_pf

  out <- data.frame(subgroup, .data[out[[2L]], ])
  row.names(out) <- NULL
  return(out)
}

.path_check_valid_weave_convert <- function(x) {
  if (.check_path_frame_uses_stack(x)) {
    stop(
      "`weave_convert()` '.path' cannot contain '+'. ",
      "Use `stack()` to prepare input."
    )
  }
}
