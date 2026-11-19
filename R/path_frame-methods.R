#' Methods for path_frame S7 container class
#' @name path_frame-methods
#' @rdname path_frame-methods
#'
#' @examples
#' # Only necessary in example
#' require(generics)
#'
#' x <- random_multifactor()
#'
#' # Generate a path_frame
#' p <- select_path(x, a ~ d)
#'
#' # Get formula notation for the full path:
#' formula(p)
#'
#' # Split path into components
#' components(p)
#'
#' @param x,object `path_frame` on which the method should be applied.
#' @returns A `path_frame` or method-appropriate value.
NULL

S7::method(formula, path_frame) <-
  function(x) `formula.multifactor::path_frame`(x)

#' @export
#' @importFrom stats formula as.formula
#'
`formula.multifactor::path_frame` <- function(x, ...) {
  res <- .build_call_string_pf(x)

  stats::as.formula(res, globalenv())
}

S7::method(components, path_frame) <-
  function(object) `components.multifactor::path_frame`(object)

#' @export
#' @importFrom generics components
`components.multifactor::path_frame` <- function(
    object, ...
) if( !.check_pf_is_fitted(object) ) {
  list(object)
} else {
  split.data.frame(object, ~component)
}

.component_apply <- function(
    X, FUN, ..., simplify = FALSE
) if( !.check_pf_is_fitted(X) ) {
  tapply(X, 1L, FUN, ..., simplify = FALSE)
} else {
  tapply(X, ~component, FUN, ..., simplify = FALSE)
}

.build_call_string_pf <- function(x) {
  out_len <- 1 + 2 * NROW(x)
  res <- rep(" ~ ", out_len)
  res[seq_len(out_len) %% 2 == 1L] <- `terms.multifactor::path_frame`(x)

  if (.check_pf_uses_coverage(x)) {
    colon_i <- .is_colon_shorthand(x)
    res[seq_len(out_len) %% 2 == 0L][colon_i] <- ":"

    which_vals <- which(.check_pf_cov_bool(x) & !colon_i)
    res[seq_len(out_len) %% 2 == 1L][which_vals +1] <- paste(
      res[seq_len(out_len) %% 2 == 1L][which_vals +1],
      x[["cov_operator"]][which_vals],
      x[["cov_value"]][which_vals]
    )
  }

  res <- paste0(res, collapse = "")
  res
}


S7::method(terms, path_frame) <- function(x) `terms.multifactor::path_frame`(x)

#' @export
`terms.multifactor::path_frame` <- function(x, ...) as.character(
  c(x[[1L]], x[[2L]][NROW(x)])
)

S7::method(print, path_frame) <- function(x, ...) {
  from_to <- .pf_from_to(x)

  p <- .component_apply(x, `formula.multifactor::path_frame`)

  cat(
    "A ", paste(setdiff(class(x), "data.frame"), collapse = " "),
    ".\n  A path from `", from_to[[1L]], "` to `", from_to[[2L]], "`",
    sep = ""
  )
  if (length(p) == 1L) {
    cat(":\n")
  } else {
    cat(" with ", length(p), " sub-paths:\n", sep = "")
  }
  for (i in seq_along(p)) {
    cat(paste0("[[", i, "]]\n"))
    print(p[[i]])
    cat("\n")
  }
  print.data.frame(x)
}
