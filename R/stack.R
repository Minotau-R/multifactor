#' Combine levels across several linkmaps in a multifactor
#' @name stack-methods
#' @rdname stack-methods
#' @description Generates a new `linkmap` object by merging levels by name,
#'     separated by the plus (`+`) sign. See examples.
#' @param x a `multifactor`
#' @param .path a `formula` of length 2 with with levels to be merged separated
#'     by the plus (`+`) sign. Optionally, a list with two character vectors,
#'     signifying the variables to be combined at the left and right hand side,
#'     respectively.
#' @param ... Additional arguments (unused.)
#' @param out.format `Character scalar`. One of `'linkmap'`, `'matrix'`.
#' @returns a `linkmap` or `sparse Matrix`.
#' @importFrom utils stack
#' @examples
#' # Only necessary in example code
#' require(utils)
#'
#' x <- random_multifactor()
#' # Merge variables with "+" operator, new names get concatenated with ".":
#' stack(x, b ~ c + d)
#'
NULL

S7::method(stack, multifactor) <- function(x, .path, out.format = c("linkmap", "matrix"), ...) `stack.multifactor::multifactor`(x, .path, out.format, ...)

#' @importFrom utils stack
#' @export
#'
`stack.multifactor::multifactor` <- function(x, .path, out.format = c("linkmap", "matrix"), ...) {
  out.format <- match.arg(out.format, c("linkmap", "matrix"))
  # Handle .path arg
  .valid_path_input(.path)
  pf <- as_path_frame(.path)
  .path_check_valid_stack(pf)

  terms <- .pf_as_stack_path_list(pf)

  res <- .stack_terms(x, terms)
  if (out.format == "matrix") {
    res <- `as.matrix.multifactor::linkmap`(res)
  }
  return(res)
}

.path_check_valid_stack <- function(x) {
  stopifnot(
    "stack does not support '.path' with multiple tildes " =
      .check_path_frame_is_minimal(x)
  )
  stopifnot(
    "At least one side of '.path' must include variables combined by '+'." =
      .check_path_frame_uses_stack(x)
  )
}

.pf_as_stack_path_list <- function(x) strsplit(
  `terms.multifactor::path_frame`(x), " + ",
  fixed = TRUE
)

.stack_terms <- function(x, terms) {
  res <- apply(
    expand.grid(terms), 1L, .stack_weave_terms_df,
    x = x, simplify = FALSE
  )
  cn <- vapply(lapply(terms, unique), paste, collapse = ".", "")
  res <- do.call(rbind.data.frame, lapply(res, `colnames<-`, cn))
  res <- linkmap(res)
  return(res)
}

.stack_weave_terms_df <- function(df, x) .stack_weave_terms(x, c(df))

.stack_weave_terms <- function(x, terms) {
  # Determine required ids in order, only keep relevant elements of link.
  all_terms <- .select_path(x, terms, NULL, NULL, NULL)
  res <- lapply(all_terms, .weave_full_path, x = x, out.format = "linkmap")
  res <- do.call(
    rbind.data.frame,
    c(res, make.row.names = FALSE, stringsAsFactors = TRUE)
  )
  return(res)
}
