#' Perform enrichtment analysis from a weave
#' @name weave_coverage-methods
#' @rdname weave_coverage-methods
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
#' .path = card ~ rank ~ straight > 0.2
#' result <- weave_coverage(scores, .path, .data = cheat)
#' result
#' test_enrich(result)
#'
NULL

S7::method(weave_coverage, multifactor) <- function(
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
  terms_pf <- terms(pf)

  # check path length:
  if (NROW(pf) == 1) {
    res <- .coverage_single_step(x, terms_pf, .data, metric)
  } else {
    if(!.check_path_frame_uses_coverage(pf)) {
      pf[["cov_operator"]][NROW(pf)] <- ">"
      pf[["cov_value"]][NROW(pf)] <- 0
    }
    res <- .coverage_reduce_loop(x, pf, terms_pf, .data, metric)
  }

  if (out.format == "matrix") {
    res <- `as.matrix.multifactor::linkmap`(res)
  }

  res
}



.coverage_single_step <- function(x, terms_pf, .data, metric) {
  res <- .weave_coverage_two(
    x[[.rows_with_col(x@map, terms_pf)]],
    terms_pf, .data, metric
  )
  res <- as_linkmap(res)
  res
}

#' @importFrom S7 prop prop<-
.coverage_reduce_loop <- function(x, pf, terms_pf, .data, metric) {
  terms_list <- .coverage_get_terms_list(terms_pf, .check_pf_cov_bool(pf))
  cov_exprs <- .get_coverage_exprs(pf)
  res_name <- paste0(terms_pf[1L], "2", tail(terms_pf, 1L))

  for(i in seq_along(terms_list)) {
    x <- .weave_coverage_by_args(x, terms_list[[i]], cov_exprs[[i]], .data)
  }

  res <- x[[res_name]]
  drop_cols <- setdiff(
    c("set_count", "set_size",  "coverage", "complete"), metric
    )

  if(length(drop_cols)) {
    res <- as.data.frame(res)
    res[drop_cols] <- NULL
    res <- as_linkmap(res)
  }
  res
}

.get_coverage_exprs <- function(pf) {
  cov_i <- .check_pf_cov_bool(pf)
  stopifnot("No coverage in path_frame input" = any(cov_i))

  res <- paste(pf[["cov_operator"]], pf[["cov_value"]])[cov_i]
  if(!tail(cov_i, 1L)) {
    res <- c(res, ">= 0")
  }
  res
}

.weave_coverage_by_args <- function(x, terms_list, cov_exprs, .data) {

  lm <- .weave_full_path(x, terms_list, "linkmap")
  from_to <- terms_list[c(1, length(terms_list))]
  lm <- .weave_coverage_two(
    lm, from_to, .data, c("set_count", "set_size", "coverage", "complete")
  )
  lm <- lm[eval(parse(text = paste("coverage", cov_exprs)), lm), , drop = FALSE]

  # Add to multifactor x
  x <- augment(x, as_linkmap(lm))

  return(x)
}




.coverage_get_terms_list <- function(x, cov_i) {
  which_cov <- which(cov_i)
  if(max(which_cov) + 1L == length(x)) {
    from_i <- c(1L, which_cov[-length(which_cov)] +1 )
    to_i <- c(which_cov + 1)
  } else {
    from_i <- c(1L, which_cov +1 )
    to_i <- c(which_cov + 1, length(x))
  }
  if( length(from_i) == 1L ) {
    res <- list( x[seq_len(to_i)] )
  } else {
    res <- vector("list", length = length(from_i))
    res[[1L]] <- x[seq_len(to_i[1L])]
    res[seq.int(from = 2L, to = length(res))] <- lapply(
      seq_along(from_i[-1]) + 1,
      function(i) x[c(1L, seq.int(from_i[i], to_i[i]))]
    )
  }
  res
}

.path_check_valid_coverage <- function(x) {
  if (.check_path_frame_uses_stack(x)) {
    stop(
      "weave_coverage() '.path' cannot contain '+'. ",
      "Use `stack()` to prepare input."
    )
  }
  # FIXME for no explicit tildes
  # if (!.check_path_frame_uses_coverage(x)) {
  #   stop(
  #     "weave_coverage() '.path' must contain coverage information."
  #   )
  # }
}

.as_cont_matrix <- function(x) {
  q <- x[1L]
  m <- x[2L]
  n <- x[3L]
  k <- x[4L]

  matrix(c(q, m - q, k - q, n - (k - q)), 2, 2)
}

#' given a linkmap x, calculate enrichment of all_terms positions 1 ~ 2,
#' with optional .data character vector
#' @noRd
.weave_coverage_two <- function(x, all_terms, .data = NULL, metric) {
  # if(S7::S7_inherits(x, multifactor)) {
  #   x <- x[[1L]]
  # }
  x <- as.data.frame(x)
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

#' @importFrom stats reformulate
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
