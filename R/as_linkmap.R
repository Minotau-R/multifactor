#' Convert common classes to linkmap or multifactor
#' @name as_linkmap-methods
#' @rdname as_linkmap-methods
#'
#' @description
#' \code{as_linkmap} and \code{as_multifactor }convert the input object(s) to a
#' \code{linkmap} and a \code{multifactor}, respectively.
#'
#' @param x \code{data.frame}, \code{list} or \code{logical matrix}. Input
#'   object(s) to convert to \code{linkmap} or \code{multifactor}.
#'
#' @param y \code{Character vector}. The vector of elements to use as
#'   feature names along with \code{x} if the latter is an unnamed list.
#'   (Default: \code{NULL}).
#'
#' @param edge.names \code{Character vector}. A vector of two elements
#'   specifying the names of the edges in the output \code{linkmap}.
#'   (Default: \code{NULL}).
#'
#' @returns
#' \code{as_linkmap} returns a \code{linkmap} where each row contains a unique
#' combination of the elements in \code{x} (and \code{y} for an unnamed list).
#' \code{as_multifactor} returns a \code{multifactor}
#'
#' @examples
#' # Create list with random linkage
#' lst <- lapply(1:3, function(x) sample(letters[seq(3)], 3, replace = TRUE))
#' names(lst) <- LETTERS[seq(3)]
#'
#' # Convert to linkmap
#' a2b <- as_linkmap(lst, edge.names = c("a", "b"))
#'
#' # Create adjacency matrix
#' mat <- matrix(sample(c(TRUE, FALSE), 3 * 3, replace = TRUE), nrow = 3)
#' rownames(mat) <- LETTERS[seq(3)]
#' colnames(mat) <- c("x", "y", "z")
#'
#' # Convert adjacency matrix to linkmap
#' b2c <- as_linkmap(mat, edge.names = c("b", "c"))
#'
#' # Convert list of lists, matrices or data.frames to multifactor
#' mf <- as_multifactor(list(X1 = lst, X2 = mat))
#'
NULL

S7::method(as_linkmap, linkmap) <- function(x) x

S7::method(as_linkmap, S7::class_data.frame) <- function(x, edge.names = NULL) {
  if (NCOL(x) >= 3L) {
    metadata <- x[, -seq_len(2L), drop = FALSE]
    x <- x[, seq_len(2L)]
  } else {
    metadata <- data.frame(row.names = seq_len(NROW(x)))
  }
  # Assign custom edge names
  if (!is.null(edge.names)) {
    colnames(x) <- edge.names
  }
  # Convert to linkmap
  x <- linkmap(x, metadata)
  return(x)
}

S7::method(as_linkmap, S7::class_list) <- function(
  x, y = NULL, edge.names = NULL
) {
  # Use list names
  if (is.null(y)) {
    y <- names(x)
  }
  # Create linkMap
  x2y <- data.frame(
    x = unlist(x, recursive = TRUE, use.names = FALSE),
    y = rep(y, lengths(x))
  )
  # Assign custom edge names
  if (!is.null(edge.names)) {
    names(x2y) <- edge.names
  }
  # Convert to linkmap
  x2y <- linkmap(x2y)
  return(x2y)
}

S7::method(as_linkmap, S7::class_logical) <- function(x, edge.names = NULL) {
  # Check that x is a matrix
  if (!is.matrix(x)) {
    stop("'x' must be a matrix.", call. = FALSE)
  }
  if (is.null(rownames(x)) || is.null(colnames(x))) {
    stop("'x' must have rownames and colnames.", call. = FALSE)
  }
  # Find link indices
  idx <- which(x, arr.ind = TRUE)
  # Find link pairs
  x2y <- data.frame(
    x = rownames(x)[idx[, 2]],
    y = colnames(x)[idx[, 1]]
  )
  # Assign custom edge names
  if (!is.null(edge.names)) {
    names(x2y) <- edge.names
  }
  # Convert to linkmap
  x2y <- linkmap(x2y)
  return(x2y)
}

S7::method(as_multifactor, S7::class_any) <- function(x, edge.names = NULL) {
  if (is.null(edge.names)) {
    edge.names <- lapply(seq_along(x), function(i) letters[c(i, i + 1)])
  }
  # Convert each element to linkmap
  mf <- mapply(as_linkmap, x = x, edge.names = edge.names, SIMPLIFY = FALSE)
  # Convert to multifactor
  mf <- multifactor(mf)
  return(mf)
}


S7::method(as_path_frame, S7::class_character) <- function(x) {
  x <- stats::as.formula(paste0(x, collapse = "~"))
  call <- .deparse_fm(x)
  x <- .path_to_path_frame_df(x)
  path_frame(x, call)
}

S7::method(as_path_frame, S7::class_formula) <- function(x) {
  call <- .deparse_fm(x)
  x <- .path_to_path_frame_df(x)
  path_frame(x, call)
}

S7::method(as_path_frame, S7::class_data.frame) <-
  function(x, call = "") path_frame(x, call)

