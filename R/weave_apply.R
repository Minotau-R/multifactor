#' Index a table by a multifactor and apply arbitrary code to it
#' @name weave_apply-methods
#' @rdname weave_apply-methods
#' @description
#' `weave_apply` can run arbitrary code specified by `FUN` across any number
#'  of row-based subsets of table `.data`. Mimics lapply.
#' @param .x a `multifactor` object.
#' @param .path either a `formula` or a `character vector`` of length 2 with the
#'     names of the desired combination of feature types.
#' @param .data `A table`. A `data.frame`, `matrix`, other object with rows and
#'     columns.
#' @param .fun A function, passed to lapply.
#' @param ... Additional arguments passed to lapply call.
#' @param .index `Character scalar` Where in `.x` can the target feature names be
#'     found. (Default: "row.names")
#' @returns a `Named list` of desired output.
#' @examples
#'
#' # Prepare data
#' set.seed(2612)
#' x <- trade_posts()
#'
#' # Generate small example feature table 'df'.
#' n <- nlevels(x)[["fruit"]]
#' df <- replicate(10, rbinom(n, rbinom(n, 100, runif(n)), runif(n)))
#'
#' #' # Ensure rownames correspond to the first (LHS) variable in the formula.
#' df <- as.data.frame(df, row.names = levels(x)$fruit)
#'
#' # Apply arbitrary code to x based on group membership
#' weave_apply(
#'   x,
#'   .path = fruit ~ clothing,
#'   .data = df,
#'   .fun = function(x) colSums(x)
#' )
#'
#' @seealso [weave()] [lapply()] [linkmap()] [multifactor()]
#'
NULL

S7::method(weave_apply, multifactor) <- function(
    .x, .path, .data, .fun = NULL, ..., .index = "row.names"
    ) {

  pf <- .check_parse_path(.x, .path, "weave_apply")

  lmp <- .weave_to_linkmap(.x, pf, .data, .coverage_metrics)

  index_lm <- .weave_res_to_index(lmp, .pf_from_to(pf), .data, .i = .index)

  IDX <- .split_linkmap(index_lm)

  # Mimic tapply behaviour; Leaving FUN = NULL returns the index itself.
  if (is.null(.fun)) {
    res <- IDX
  } else {
    FUN <- match.fun(.fun)
    # Apply FUN over each subset of X indexed by IDX
    res <- lapply(X = IDX, FUN = function(iii) FUN(.data[iii, ]), ...)
  }
  return(res)
}


#' @noRd
#'
.weave_to_linkmap <- function(x, pf, .data, metric) {
  if(.check_pf_uses_coverage(pf)) {
    pfs <- split.data.frame(pf, ~components)
    lmp <- lapply(
      pfs, .weave_cov_full_path, x = x, .data = .data, metric = metric
    )
    lmp <- do.call(rbind.data.frame, lmp)
    lmp <- as_linkmap(lmp)
  } else {
    full_path <- .pf_as_full_path_list(pf)
    lmp <- lapply(full_path, .weave_full_path, x = x)
    lmp <- do.call(rbind.data.frame, lmp)
    lmp <- linkmap(lmp)
  }
  lmp
}

#' Index a table
#' @name .weave_res_to_index
#' @rdname index_tbl
#' @description
#' `.weave_res_to_index()` finds row indices for input table `.data`,
#' based on a user-defined path through a linkmap
#' @noRd
#'
.weave_res_to_index <- function(lmp, range_pf, .data, .i = "row.names", ...) {
  .data <- .index_tbl(.data, type = range_pf[[1L]], .i = .i)

  x <- multifactor(list(lmp, .data))
  all_terms <- c(rev(range_pf), colnames(.data)[[2L]])

  res <- .weave_full_path(x, all_terms)
  res[[2L]] <- as.integer(res[[2L]])
  res
}


#' Index a table
#' @name .index_tbl_by_path_list
#' @rdname index_tbl
#' @description
#' `.index_tbl()` is a utility function that flexibly takes a table as input and
#' returns a special `linkmap` object that has (1) row names and (2)
#' corresponding row indices of that table as columns.
#'
#' @param type `Character scalar` Specifies name of the feature type, will be
#'     used as name of the first column in output.
#' @param .i `Character scalar` column with features. Defaults to `rownames(X)`
#' @noRd
#' @examples
#' # Any table can be a indexed into a linkmap:
#' .index_tbl(mtcars)
#'
.index_tbl <- function(.data, type = deparse1(substitute(.data)), .i = "row.names") {
  if (.i == "row.names") {
    row.index <- rownames(.data)
  } else {
    row.index <- .data[[.i]]
  }
  res <- data.frame(row.index, seq_len(NROW(.data)))

  colnames(res) <- c(type, "row.index")
  as_linkmap(res)
}


#' @noRd
.split_linkmap <- function(x, drop = TRUE) split.default(
  x[[2L]], x[[1L]], drop
)

#' Take the coverage .data arg and return a character vector.
#' @noRd
#'
.data_coverage_to_vector <- function(.data, .i = "row.names") {
  if (!length(.data)) {
    res <- NULL
  } else if (is.character(.data)) {
    res <- .data
  } else {
    if (.i == "row.names") {
      res <- row.names(.data)
    } else {
      res <- .data[[.i]]
    }
  }
  return(res)
}
