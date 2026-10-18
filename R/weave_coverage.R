#' Perform enrichtment analysis from a weave
#' @param x a `multifactor`
#' @param .path Either a `formula` or a `character vector` of length 2 with the
#'     names of the desired combination of feature types.
#' @param .data Optional `Character vector`. Lists observed features from the
#'     found within the first element of `.path`. Alternatively, a `data.frame`
#'     with the same information. (Also see `.data_column` argument).
#' @param metric `Character scalar`.
#'     One or more of `'set_count'`, `'set_size'`, `'coverage'`, `'complete'`.
#' @param out.format `Character scalar`.
#'     One of `'linkmap'`, `'matrix'`.
#' @param .data_column `Character scalar`. if `.data` is a table, where to find
#'     feature IDs
#' @returns a `linkmap` or `matrix` with the desired coverage information in
#'     the @metadata slot.
#' @export
#' @examples
#' set.seed(2612)
#' # Draw five cards from a deck
#' drawn <- draw_cards(5)
#' drawn
#' scores <- poker_scores()
#' scores
#'
#' # Now enrich input
#' result <- weave_coverage(
#'   x = scores, .path = card ~ suit, .data = drawn, metric = "set_count"
#' )
#'
#' result
#'
#' # Now let's spike our hand with a royal straight flush
#' cheat <- draw_cards()[c(10, 11, 12, 13, 1)]
#' cheat
#'
#' .path = card ~ straight
#' result <- weave_coverage(scores, card ~ straight, .data = cheat)
#' result
#' test_enrichment(result)
#'
weave_coverage <- function(
        x, .path, .data = NULL,
        metric = c("set_count", "set_size", "coverage", "complete"),
        out.format = c("linkmap", "matrix"), .data_column = "row.names"
) {
    metric <- match.arg(
        metric, c("set_count", "set_size", "coverage", "complete"),
        several.ok = TRUE
    )
    out.format <- match.arg(out.format, c("linkmap", "matrix"))
    .data <- .data_coverage_to_vector(.data, .data_column)

    .valid_path_input(.path)
    pf <- as_path_frame(.path)
    .path_check_valid_coverage(pf)

    pf <- .select_enframe_path(x, pf)

    full_path <- .pf_as_full_path_list(pf)

    res <- lapply(
        full_path, .weave_coverage_factor_path,
        x = x, .data = .data, metric = metric
    )

    res <- do.call(rbind.data.frame, res)
    res <- as_linkmap(res)
    if (out.format == "matrix") {
        res <- `as.matrix.multifactor::linkmap`(res)
    }
    res
}


.weave_coverage_simple <- function(
    x, .path, .data = NULL,
    metric = c("set_count", "set_size", "coverage", "complete"),
    out.format = c("linkmap", "matrix"), .data_column = "row.names"
) {
  metric <- match.arg(
    metric, c("set_count", "set_size", "coverage", "complete"),
    several.ok = TRUE
  )
  out.format <- match.arg(out.format, c("linkmap", "matrix"))
  .data <- .data_coverage_to_vector(.data, .data_column)

  .valid_path_input(.path)
  pf <- as_path_frame(.path)
  .path_check_valid_coverage(pf)

  pf <- path_frame(.select_enframe_path(x, pf))

  # check path length:
  if (NROW(pf) == 1) {
  res <- .weave_coverage_two(x, terms(pf), .data, metric)
  } else {
    # We weave() from 'from' to the first instance of coverage:
    # a ~ <....> : c. so we weave(a ~ c)
    # Then we compute coverage on a ~ c and optionally filter.
    #
    # From there, proceed to weave to the next instance of coverage.
    # weave(a  ~ c+1 ~ .... : c2)
    # etc.
    #
    stop("TO DO")
  }
  as_linkmap(res)

}

.path_check_valid_coverage <- function(x) {
  if (.check_path_frame_uses_stack(x)) {
    stop(
      "weave_coverage() '.path' cannot contain '+'. ",
      "Use `stack()` to prepare input."
    )
  }
}



.weave_coverage_factor_path <- function(x, full_path, .data, metric) {
  stopifnot(
    "weave_coverage() '.path' must be 2 or 3 steps long." =
      length(full_path) %in% c(2L, 3L)
  )
  x <- .subset_by_path(x, full_path)

  # check if .data argument is present
  if (length(.data)) {
    if (length(full_path) == 2L) {
      res <- .weave_coverage_two(x, full_path, .data, metric)
    } else if (length(full_path) == 3L) {
      res <- .weave_coverage_three(x, full_path, .data, metric)
    }
  }

  return(res)
}


#' @importFrom S7 S7_inherits
#' @importFrom stats p.adjust
#' @param x A linkmap with coverage metadata from `weave_coverage()`.
#' @param log_base `Integer`. Base of logarithm for log-fold (default: 2).
#' @export
#' @rdname weave_coverage
#' @name test_enrichment
#'
test_enrichment <- function(x, log_base = 2L) {
  stopifnot(
    "'x' must be a linkmap." = S7::S7_inherits(x, linkmap),
    "No coverage data found in metadata. Run `weave_coverage()` first." =
      all(c("observed", "set_count", "set_size") %in% colnames(x@metadata))
  )
  i <- stats::reformulate(colnames(x)[[2L]])
  mm <- as.data.frame(x)

  # q = actual hits, m = possible hits, n = possible misses, k = n_draws
  q <- tapply(mm, i, function(xx) unique(xx[["set_count"]]))
  m <- tapply(mm, i, function(xx) unique(xx[["set_size"]]))
  n <- nlevels(mm[[1L]]) - unlist(m)
  k <- length(unique(mm[mm[["observed"]], 1L]))

  cont_df <- data.frame(q, m, n, k)

  expected <- k / (m + n)
  observed <- q / m
  fold <- observed / expected
  log_fold <- log(fold, log_base)
  p.value <- apply(cont_df, 1L, .apply_phyper)
  p.adj <- stats::p.adjust(p.value, method = "BH")

  res <- data.frame(expected, observed, fold, log_fold, p.value, p.adj)

  # Some residual code
  # cont_list <- apply(cont_df, 1L, .as_cont_matrix, simplify = FALSE)
  #
  # lapply(cont_list, fisher.test)
  # lapply(cont_list, chisq.test)

  return(res)
}

#' @importFrom stats phyper
.apply_phyper <- function(x) phyper(
  x[[1L]] - 1L, x[[2L]], x[[3L]], x[[4L]],
  lower.tail = FALSE
)

.as_cont_matrix <- function(x) {
  q <- x[1L]
  m <- x[2L]
  n <- x[3L]
  k <- x[4L]

  matrix(c(q, m - q, k - q, n - (k - q)), 2, 2)
}


#' @noRd
#' @examples
#' x <- random_multifactor()[seq_len(2L)]
#' at <- c("a", "b", "c")
#' x.cov <- .weave_coverage_three(x, all_terms = at, metric = "coverage")
#' x.cnt <- .weave_coverage_three(x, all_terms = at, metric = "set_count")
#' x.cpt <- .weave_coverage_three(x, all_terms = at, metric = "complete")
#'
#' x.cov@metadata
#' x.cnt@metadata
#' x.cpt@metadata
#'
#' @importFrom Matrix Matrix crossprod colSums t
#'
.weave_coverage_three <- function(x, all_terms, .data, metric) {
  # All steps in order
  from <- all_terms[[1L]]
  shared <- all_terms[[2L]]
  to <- all_terms[[3L]]

  seen <- x[[.rows_with_col(x@map, c(shared, from))]]
  full <- x[[.rows_with_col(x@map, c(shared, to))]]

  # Ensure linkmap order
  shared2from <- as.matrix(seen, terms = c(shared, from))
  shared2to <- as.matrix(full, terms = c(shared, to))

  # Link observed features to sets
  bg_mat <- Matrix::t(
    Matrix::Matrix(
      Matrix::crossprod(shared2to, shared2from != 0L),
      sparse = TRUE
    )
  )

  if (length(.data)) {
    bg <- .res_weave_matrix_to_linkmap(bg_mat, levels(x)[c(from, to)])

    obs <- bg[bg[[from]] %in% .data, ]
    res <- .calc_coverage_cont_table(bg, obs, to, metric)
  } else {
    bg <- Matrix::colSums(shared2to)
    obs <- bg_mat
    full_set <- .res_weave_matrix_to_linkmap(bg_mat, levels(x)[c(from, to)])
    res <- .calc_coverage_cont_table_no_data(bg, obs, full_set, metric)
  }

  return(res)
}

#' @importFrom Matrix colSums
#' @importFrom stats reformulate
#' @importFrom S7 S7_data
#'
.weave_coverage_two_old <- function(x, all_terms, .data, metric) {
  set_unit <- all_terms[[1L]]
  set_full <- all_terms[[2L]]
  x.lm <- x[[1L]]
  bg <- `class<-`(S7::S7_data(x.lm), "data.frame")
  if (length(.data)) {
    obs <- bg[bg[[set_unit]] %in% .data, ]
  } else {
    obs <- bg
  }
  res <- .calc_coverage_cont_table(bg, obs, set_full, metric)
  res
}

#' given a linkmap x, calculate enrichment of all_terms positions 1 ~ 2,
#' with optional .data character vector
#' @noRd
.weave_coverage_two <- function(x, all_terms, .data = NULL, metric) {
  x <- as.data.frame(x[[1L]])
  unit_term <- all_terms[[1L]]
  set_term <- all_terms[[2L]]

  if (length(.data)) {
    unit_obs <- x[x[[unit_term]] %in% .data, ]
  } else {
    unit_obs <- x
  }
  res <- .calc_coverage_cont_table(x, unit_obs, set_term, metric)
  res
}

.calc_coverage_cont_table <- function(bg, obs, set_term, metric) {
  tot_set <- pmax.int(
    c(tapply(bg, INDEX = stats::reformulate(set_term), FUN = NROW)), 1L
  )
  obs_set <- c(tapply(obs, INDEX = stats::reformulate(set_term), FUN = NROW))
  val <- data.frame(
    set_count = obs_set,
    set_size  = tot_set,
    coverage  = obs_set / tot_set,
    complete  = obs_set == tot_set
  )[metric]

  metadata <- val[match(bg[[set_term]], row.names(val)), , drop = FALSE]
  observed <- bg[[1L]] %in% obs[[1L]]
  res <- cbind.data.frame(bg, observed, metadata)

  row.names(res) <- NULL
  return(res)
}

.calc_coverage_cont_table_no_data <- function(bg, obs, full_set, metric) {
  tot_set <- pmax.int(bg, 1L)
  obs_set <- apply(obs, 2L, c, simplify = FALSE)

  val_list <- mapply(
    FUN = function(obs_set, tot_set) data.frame(
      set_count = obs_set,
      set_size  = tot_set,
      coverage  = obs_set / tot_set,
      complete  = obs_set == tot_set
    )[metric], obs_set, tot_set, SIMPLIFY = FALSE
  )

  res_list <- lapply(
    val_list, function(val) {
      metadata <- val[match(full_set[[1L]], row.names(val)), , drop = FALSE]
      observed <- full_set[[1L]] %in% row.names(val)
      cbind.data.frame(full_set, observed, metadata)
    }
  )

  res <- do.call(rbind.data.frame, c(res_list, make.row.names = FALSE))

  return(res)
}
