#' Methods for path_frame S7 container class
#' @name path_frame-methods
#' @rdname path_frame-methods
#'
#' @examples
#' x <- random_multifactor()
#'
#' # Generate a path_frame
#' p <- select_path(x, a ~ d)
#'
#' # Get formula notation for the full path:
#' formula(p)
#'
#' @param x,object `path_frame` on which the method should be applied.
#' @returns A `path_frame` or method-appropriate value.
NULL

S7::method(formula, path_frame) <- function(x) `formula.multifactor::path_frame`(x)

#' @export
#' @importFrom stats formula as.formula
#'
`formula.multifactor::path_frame` <- function(x, ...) {
  res <- .build_call_string_pf(x)

  stats::as.formula(res, globalenv())
}

.build_call_string_pf <- function(x) {
  out_len <- 1 + 2 * NROW(x)
  res <- rep(" ~ ", out_len)
  res[seq_len(out_len) %% 2 == 1L] <- `terms.multifactor::path_frame`(x)

  if (.check_path_frame_uses_coverage(x)) {
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
  from_to <- terms(x)[c(1, NROW(x) + 1L)]

  if (has_comps <- "components" %in% colnames(x)) {
    p <- tapply(
      x, ~components, `formula.multifactor::path_frame`,
      simplify = FALSE
    )
  } else {
    p <- list(formula(x))
  }

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
  for (i in length(p)) {
    print(p[[1]])
    cat("\n")
  }
  print.data.frame(x)
}
