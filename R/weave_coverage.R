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
#'     One or more of `'set_count'`, `'set_size'`, `'coverage'`.
#'     All are returned by default.
#' @param out.format `Character scalar`.
#'     One of `'linkmap'`, `'matrix'`.
#' @param .data_column `Character scalar`. if `.data` is a table, where to find
#'     feature IDs
#' @param subset `Logical scalar`. Whether to drop levels of the 'from' feature
#'     type that don't satisfy conditions in '.path' (Default: `TRUE`).
#'     `test_enrich()` calls `weave_coverage()` with `subset = FALSE`.
#' @returns a `linkmap` or `matrix` with the desired coverage information in
#'     the @metadata slot.
#' @examples
#' # Load the quick brown fox data set
#' x <- quickbrownfox()
#' .data <- c("t", "h", "e", "f", "o", "x")
#' .path1 <- letter ~ word ~ constituent
#' .path2 <- letter : word ~ constituent
#' .path3 <- letter ~ word > 0.5 ~ constituent
#' .path4 <- letter : word ~ constituent > 0.25
#'
#' weave_coverage(x = x, .path = .path1, .data = .data)
#' weave_coverage(x = x, .path = .path2, .data = .data)
#' weave_coverage(x = x, .path = .path3, .data = .data)
#' weave_coverage(x = x, .path = .path4, .data = .data)
#'
NULL

.coverage_metrics <- c("set_count", "set_size", "coverage")

S7::method(weave_coverage, multifactor) <- function(
    x, .path, .data = NULL, subset = TRUE,
    metric = c("set_count", "set_size", "coverage"),
    out.format = c("linkmap", "matrix"), .data_column = "row.names"
) {
  metric <- match.arg(
    metric, .coverage_metrics,
    several.ok = TRUE
  )
  out.format <- match.arg(out.format, c("linkmap", "matrix"))

  .data <- .data_coverage_to_vector(.data, .data_column)

  pf <- .check_parse_path(x, .path, "weave_coverage")

  res <- .component_apply(
    pf, .weave_cov_full_path,
    x = x, .data = .data, metric = metric
    )

  res <- do.call(rbind.data.frame, res)
  res <- as_linkmap(res)

  if(subset) {
    res <- res[res@metadata[["observed"]]]
  }

  if (out.format == "matrix") {
    res <- `as.matrix.multifactor::linkmap`(res)
  }
  res
}

.weave_cov_full_path <- function(x, pf, .data, metric) {
  # Take unmodified terms
  terms_pf <- terms(pf)
  # check path length:
  if (NROW(pf) == 1) {
    res <- .linkmap_add_coverage(
      x[[.rows_with_col(x@map, terms_pf)]], terms_pf, .data, metric
    )
  } else {
    if(!.check_pf_uses_coverage(pf)) {
      pf[["cov_operator"]][NROW(pf)] <- ">"
      pf[["cov_value"]][NROW(pf)] <- 0
    }
    res <- .coverage_reduce_loop(x, pf, terms_pf, .data, metric)
  }
  res
}


#' @importFrom S7 prop prop<-
.coverage_reduce_loop <- function(x, pf, terms_pf, .data, metric) {

  res <- .coverage_for_loop(x, pf, terms_pf, .data)

  if(.check_needs_backweave(pf)) {
    x_bw <- weave_coverage(
      x, formula(paste0(terms_pf, collapse = "~")),  metric = c("set_size")
    )
    res <- .backweave_adjust_res(res, x_bw, terms_pf)
  }

  if( length(drop_cols <- setdiff(.coverage_metrics, metric)) ) {
    res[drop_cols] <- NULL
  }
  res
}

#' @noRd
#' @description
#' Returns a boolean answering the question:
#' Does this coverage calculation need a 'background' weave (without thresholds)
#' to properly find the background set size?
#'
.check_needs_backweave <-
  function(pf) sum(.check_pf_cov_bool(pf)[-NROW(pf)]) >= 1L

.backweave_adjust_res <- function(res, x_bw, terms_pf) {
  to_from <- c(tail(terms_pf, 1L), terms_pf[1L])
  x_bw <- as.data.frame(x_bw)
  x_bw[["observed"]] <- NULL

  res <- sort_by.data.frame(
    merge( x_bw, res[c(to_from, "observed")], all.x = TRUE ),
    stats::reformulate(to_from)  )

  res[["observed"]][is.na(res[["observed"]])] <- FALSE

  res[["set_count"]] <- unlist(
    tapply(
      res, stats::reformulate(to_from[1]),
      function(ii) {
        n_obs <- sum(ii[["observed"]])
        times <- unique(ii[["set_size"]])
        if(length(times) == 0L) {
          rep.int(n_obs, 0L)
        } else {
          rep.int(n_obs, times)
        }
      },
      simplify = FALSE), FALSE, FALSE
  )
  res[["coverage"]] <- res[["set_count"]] / res[["set_size"]]
  res
}


.coverage_for_loop <- function(x, pf, terms_pf, .data) {
  terms_list <- .coverage_get_terms_list(terms_pf, .check_pf_cov_bool(pf))
  cov_exprs <- .get_coverage_exprs_only(pf)

  for(i in seq_along(terms_list)) {
    x <- .weave_coverage_by_args(x, terms_list[[i]], cov_exprs[[i]], .data)
  }
  res <- x[[.rows_with_col(x@map, .pf_from_to(pf))]]
  as.data.frame(res)
}

.get_coverage_exprs <- function(pf) {
  cov_i <- .check_pf_cov_bool(pf)
  stopifnot("No coverage in path_frame input" = any(cov_i))

  res <- paste(pf[["cov_operator"]], pf[["cov_value"]])
  if(!tail(cov_i, 1L)) {
    res <- c(res, ">= 0")
  }
  res
}

.get_coverage_exprs_only <- function(pf) {
  cov_i <- .check_pf_cov_bool(pf)
  stopifnot("No coverage in path_frame input" = any(cov_i))

  res <- paste(pf[["cov_operator"]], pf[["cov_value"]])[cov_i]
  if(!tail(cov_i, 1L)) {
    res <- c(res, ">= 0")
  }
  res
}

.weave_coverage_by_args <- function(x, terms_list, cov_exprs, .data) {

  lm <- .weave_full_path(x, terms_list)
  from_to <- terms_list[c(1L, length(terms_list))]
  lm <- .linkmap_add_coverage(
    lm, from_to, .data, .coverage_metrics
  )
  lm <- lm[eval(parse(text = paste("coverage", cov_exprs)), lm), , drop = FALSE]

  # Add to multifactor x
  x <- augment(x, as_linkmap(lm))
  x
}


.coverage_get_terms_list <- function(x, cov_i) {
  which_cov <- which(cov_i)
  if(max(which_cov) + 1L == length(x)) {
    from_i <- c(1L, which_cov[-length(which_cov)] + 1 )
    to_i <- c(which_cov + 1)
  } else {
    from_i <- c(1L, which_cov + 1 )
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
  if (.check_pf_uses_stack(x)) {
    stop(
      "weave_coverage() '.path' cannot contain '+'. ",
      "Use `stack()` to prepare input."
    )
  }
}

.as_cont_matrix <- function(x) {
  q <- x[1L]
  m <- x[2L]
  n <- x[3L]
  k <- x[4L]

  matrix(c(q, m - q, k - q, n - (k - q)), 2L, 2L)
}

#' given a linkmap x, calculate enrichment of all_terms positions 1 ~ 2,
#' with optional .data character vector
#' @noRd
.linkmap_add_coverage <- function(x, all_terms, .data = NULL, metric) {
  unit_term <- all_terms[[1L]]
  set_term <- all_terms[[2L]]
  if(colnames(x)[2] == unit_term) {
    x <- `rev.multifactor::linkmap`(x)
  }
  x <- as.data.frame(x)
  if (length(.data)) {
    unit_obs <- x[x[[unit_term]] %in% .data, ]
  } else {
    unit_obs <- x
  }
  .calc_coverage_cont_table(x, unit_obs, set_term, metric)
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
    coverage  = obs_set / tot_set
  )[metric]

  metadata <- val[match(bg[[set_term]], row.names(val)), , drop = FALSE]
  observed <- bg[[1L]] %in% obs[[1L]]
  res <- cbind.data.frame(bg, observed, metadata)

  row.names(res) <- NULL
  return(res)
}
