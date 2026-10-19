#' Tools to modify multifactors
#' @name augment-subset
#' @rdname augment-subset
#' @description
#' Generates a new `multifactor` object by cross-referencing the elements of a
#'     given `multifactor`.
#' @param x a `multifactor` or `linkmap`.
#' @param ... Name-value pairs. The name gives the name of the linkmap in the
#'     output.
#' @returns a `multifactor`.
#' @examples
#' # Only necessary in example code
#' require(generics)
#' # Generate a random multifactor
#' x <- random_multifactor()
#'
#' # Use augment to chain together operations like weave and stack, in order.
#' augment(
#'   x,
#'   weave(x, a ~ c),
#'   stack(x, a + b ~ c + d),
#'   weave(x, d ~ f)
#' )
#'
#' # Setting a linkmap to NULL by name deletes it from the multifactor
#' augment(x, a2b = NULL)
#'
NULL


#' @export
#' @rdname augment-subset
#' @name augment.multifactor
#' @param .path Either a `formula` or a `character vector`.
#' @param .drop.unmatched `Boolean`. Whether to drop factor levels that do not
#'     appear in the data (Default: keep all levels).
#' @aliases subset.multifactor::multifactor
#'
`subset.multifactor::multifactor` <- function(x, .path, .drop.unmatched = FALSE, ...) {
  if (.drop.unmatched) x <- .trim_multifactor(x)

  .valid_path_input(.path)
  pf <- as_path_frame(.path)
  .path_check_valid_subset(pf)

  path_list <- terms(pf)

  x <- .subset_by_path(x, path_list)
  return(x)
}

#' @export
#' @rdname augment-subset
#' @name subset.linkmap
#' @aliases subset.multifactor::linkmap
#' @param subset Logical expression indicating elements or rows to keep.
#'     If `NULL` (Default), subsets based on complete coverage if available.
#'
`subset.multifactor::linkmap` <- function(x, subset = NULL, ...) {
  df <- as.data.frame(x)
  if (is.null(subset)) {
    if ("complete" %in% colnames(df)) {
      i <- df[["complete"]]
    } else {
      i <- rep_len(TRUE, NROW(df))
    }
  } else {
    e <- substitute(subset)
    i <- eval(e, df, enclos = parent.frame())
  }
  # Indexing a Linkmap takes a single value.
  res <- x[i]
  return(res)
}

.path_check_valid_subset <- function(x) {
  if (.check_path_frame_uses_stack(x)) {
    stop(
      "subset() '.path' cannot contain '+'.",
      "Use `stack()` to prepare input."
    )
  }
}

method(subset, multifactor) <- function(x, .path, .drop.unmatched = FALSE, ...) `subset.multifactor::multifactor`(
  x, .path, .drop.unmatched
)

method(subset, linkmap) <- function(x, subset = NULL, ...) `subset.multifactor::linkmap`(
  x,
  subset = NULL, ...
)

#' @importFrom generics augment
#'
S7::method(augment, multifactor) <-
  function(x, ...) `augment.multifactor::multifactor`(x, ...)

#' @export
#' @rdname augment-subset
#' @name augment.multifactor
#' @importFrom rlang dots_list
#'
`augment.multifactor::multifactor` <- function(x, ...) {
  old_names <- rownames(x)
  dots <- rlang::dots_list(...)
  dot_names <- names(dots)
  for (i in seq_along(dot_names)) {
    res <- eval(dots[[i]], envir = x, enclos = parent.frame())
    res_name <- dot_names[i]
    if (res_name == "") {
      res_name <- .linkmap2name(res)
    }

    if (res_name %in% old_names) {
      x[[res_name]] <- res
    } else {
      x <- c(x, res)
    }
  }
  return(x)
}

#' Safely get all names from a multifactor as a data.frame.
#' @noRd
#'
.all_names_in_list_mf <- function(x) {
  as.data.frame.matrix(
    t(vapply(
      X = x,
      FUN = function(i) return(names(i)),
      FUN.VALUE = c(NA_character_, NA_character_)
    ))
  )
}
