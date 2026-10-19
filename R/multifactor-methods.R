#' Methods for multifactor S7 container class
#' @name multifactor-methods
#' @rdname multifactor-methods
#' @examples
#' # Setup
#' a2b <- data.frame(
#'   a = sample(letters[seq(3)], 10, replace = TRUE),
#'   b = sample(LETTERS[seq(3)], 10, replace = TRUE)
#' )
#' a2c <- data.frame(
#'   a = sample(letters[seq(3)], 10, replace = TRUE),
#'   c = sample(LETTERS[seq(3)], 10, replace = TRUE)
#' )
#'
#' # Create multifactor
#' x <- multifactor(list(a2b, a2c))
#'
#' # Basic properties
#' dim(x)
#' dimnames(x)
#'
#' # Factor-like properties
#' levels(x)
#' nlevels(x)
#'
#' # Retain multifactor structure using `[`.
#' x["a2b"]
#'
#' # Or extract individual linkmaps using `[[`
#' x[["a2c"]]
#'
#' # Subset by a path
#' subset(x, a ~ c)
#'
#' # Unused features will be dropped unless specified:
#' subset(x, a ~ c, drop.unmatched = FALSE)
#'
#' # Combine using `c`:
#' c(x[2], x[1])
#'
#' @param x,object `multifactor` on which the method should be applied.
#' @returns A `multifactor`
NULL

#' @param use.names `Boolean scalar` Whether tho provide names.
#'     (Default: `TRUE`)
#' @noRd
#'
S7::method(nlevels, multifactor) <-
  function(x, use.names = TRUE) lengths(levels(x), use.names)

S7::method(str, multifactor) <- function(object, ...) {
  Matrix::printSpMatrix(object@map)
  str(levels(object))
}

S7::method(print, multifactor) <- function(x, ...) {
  cat(
    "A ", paste(class(x), collapse = " "),
    ",\n    ", NCOL(x),
    " feature types across ",
    NROW(x),
    " linkmaps.\n\n",
    sep = ""
  )
  Matrix::printSpMatrix(x@map)
  cat(
    "\nValues represent unique feature names in that linkmap.\n\n",
    "@ levels:\n",
    sep = ""
  )
  .print_levels(x)

  invisible(NULL)
}

.print_levels <- function(x) {
  # Establish print sizes
  id_w <- max(nchar(colnames(x)))
  nm_w <- max(nchar(lengths(levels(x), use.names = FALSE)))
  fr_w <- getOption("width") - id_w - nm_w - 15

  for (id in colnames(x)) {
    num_lvs <- length(levels(x)[[id]])
    cat(
      " $ ",
      format(id, width = id_w),
      " : ",
      format(num_lvs, width = nm_w),
      " Levels: ",
      sep = ""
    )

    if (num_lvs > 4L) {
      n_show <- floor(fr_w / 20) - 1
      show_lvs <- levels(x)[[id]][c(seq(n_show), num_lvs)]
      show_lvs <- c(show_lvs[seq(n_show)], "...", show_lvs[n_show + 1])
      cat(
        ifelse(nchar(show_lvs) > 20,
          paste0(substring(show_lvs, 1, 16), ".."),
          show_lvs
        ),
        "\n",
        sep = " "
      )
    } else {
      cat(levels(x)[[id]], "\n", sep = " ")
    }
  }
}

S7::method(levels, multifactor) <- function(x) {
  x@levels
}
#' @export
`levels<-.multifactor::multifactor` <- function(x, value) {
  .set_levels_multifactor(x, value)
}

S7::method(dimnames, multifactor) <- function(x) {
  dimnames(x@map)
}

S7::method(dim, multifactor) <- function(x) {
  dim(x@map)
}

local({
  S7::method(`[`, multifactor) <- function(x, i) {
    if (rlang::is_missing(i)) return(x)
    multifactor(base::`[`(S7::S7_data(x), i), levels = levels(x))
  }

  S7::method(`[[`, multifactor) <- function(x, i) base::`[[`(S7::S7_data(x), i)
})


#' @export
#'
`[<-.multifactor::multifactor` <- function(x, i, value) {
  multifactor(base::`[<-`(S7::S7_data(x), i, value))
}

#' @export
#'
`[[<-.multifactor::multifactor` <- function(x, i, value) {
  multifactor(base::`[[<-`(S7::S7_data(x), i, value))
}

#' @export
#'
`c.multifactor::multifactor` <- function(...) {
  x <- list(...)
  # Figure out content
  lms <- vapply(x, S7::S7_inherits, linkmap, FUN.VALUE = FALSE)
  mfs <- vapply(x, S7::S7_inherits, multifactor, FUN.VALUE = FALSE)
  stopifnot(
    "Arguments must be multifactor or linkmap" = sum(lms, mfs) == length(x)
  )
  # Gather all levels
  lv_list <- lapply(x[mfs], levels)
  if (any(lms)) {
    lm_lst <- x[lms]
    lv_list <- c(lv_list, list(.build_levels_from_lm_list(lm_lst)))
  }
  all_lvs <- unique(unlist(lapply(lv_list, names), FALSE, FALSE))
  all_lvs <- .reduce_level_list(lv_list, all_lvs)

  # Construct main data
  x <- lapply(x[mfs], S7::S7_data)
  if (any(lms)) x <- c(x, list(lm_lst))
  x <- unlist(x, FALSE, FALSE)
  # Plug both into multifactor
  multifactor(x, levels = all_lvs)
}

.reduce_level_list <- function(lv_list, all_lvs) {
  res <- lapply(
    all_lvs,
    function(lv) {
      res <- lapply(lv_list, `[[`, lv)
      res <- Reduce(union, res, init = character())
      return(res)
    }
  )
  names(res) <- all_lvs
  return(res)
}
