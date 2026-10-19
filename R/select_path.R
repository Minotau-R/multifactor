#' Define a path through a multifactor object.
#' @name select_path-methods
#' @rdname select_path-methods
#' @param x input object
#' @param .path either a `formula` or a `character vector` of length 2 with the
#'     names of the desired combination of feature types.
#' @returns a `factor_path` object.
#' @examples
#' # Generate pair of random linkage input
#' a2b <- data.frame(
#'   a = sample(letters[seq(3)], 10, replace = TRUE),
#'   b = sample(LETTERS[seq(3)], 10, replace = TRUE)
#' )
#' a2c <- data.frame(
#'   a = sample(letters[seq(3)], 10, replace = TRUE),
#'   c = sample(c("x", "y", "z"), 10, replace = TRUE)
#' )
#'
#' # Create multifactor
#' x <- multifactor(list(a2b, a2c))
#'
#' # Inspect a path between data types
#' select_path(x, b ~ c)
#'
NULL

#' @importFrom igraph as_ids
#'
S7::method(select_path, multifactor) <- function(x, .path, ...) {
  .valid_path_input(.path)
  pf <- as_path_frame(.path)
  .path_check_valid_select(pf)

  paths <- .select_enframe_path(x, pf)
  path_frame(paths)
}

.path_check_valid_select <- function(x) {
  if (.check_path_frame_uses_stack(x)) {
    stop(
      "`weave_select()` '.path' cannot contain '+'.",
      "Use `stack()` to prepare input."
    )
  }
}


#' @importFrom dplyr bind_rows
#' @importFrom utils tail
.select_enframe_path <- function(x, pf) {
  terms_pf <- terms(pf)
  include <- terms_pf[-c(1L, length(terms_pf))]
  from_to <- terms_pf[c(1L, length(terms_pf))]

  if (!length(include)) {
    include <- NULL
  }
  full_path <- .select_path(x, from_to, include)

  i <- lapply(full_path, .path_to_path_frame_df)


  if(any(cov_i <- .check_pf_cov_bool(pf))) {
    cov_exprs <- .get_coverage_exprs(pf)

    cov_vars <- vapply(
      .coverage_get_terms_list(terms_pf, cov_i), tail, 1L,
      FUN.VALUE = character(1L)
    )

    i <- lapply(i, .restore_coverage, cov_vars, cov_exprs)
  }


  res <- dplyr::bind_rows(i, .id = "components")
  col_order <- c(seq.int(from = 2L, to = NCOL(res)), 1L)

  res <- res[, col_order, drop = FALSE]

  res
}

.restore_coverage <- function(x, cov_vars, cov_exprs) {
  inds <- lapply(cov_vars, match, x[["to"]])

  if(any(lengths(inds) > 1L)) {
    inds[[1L]] <- min(inds[[1L]])
    for(i in seq.int(2L, length(inds))) {
      inds[[i]] <- min(inds[[i]][inds[[i]] > inds[[i-1]]])
    }
  }

  inds <- unlist(inds, FALSE, FALSE)
  ops <- unlist(strsplit(cov_exprs, " ", fixed = TRUE))
  vals <- as.numeric(ops[seq_along(ops) %% 2L == 0L])
  ops  <- ops[seq_along(ops) %% 2L == 1L]

  x <- `[<-`(x, inds, match("cov_value", colnames(x)), vals)
  x <- `[<-`(x, inds, match("cov_operator", colnames(x)), ops)

  x
}

.select_path <- function(x, terms, include = NULL, exclude = NULL, exact = NULL) {
  g <- `as.igraph.multifactor::multifactor`(x)
  g <- .subset_paths(g, include, exclude, exact)
  # Use apply + unlist to support multiple variables on either side of .path
  term.grid <- expand.grid(as.list(terms))
  if (!is.null(include)) {
    paths <- .shortest_path_include(term.grid, g, include)
  } else {
    paths <- apply(term.grid, 1L, .apply_shortest_ps, g)
    paths <- lapply(unlist(paths, FALSE, FALSE), as_ids)
  }
  return(paths)
}

.apply_shortest_ps <- function(terms, g) {
  igraph::all_shortest_paths(
    g,
    from = terms[1], to = terms[2]
  )[["vpaths"]]
}

.subset_paths <- function(g, include, exclude, exact) {
  # Defenses
  if (length(dupes <- intersect(include, exclude)) != 0L) stop(
    "Cannot 'include' and 'exclude' simultaneously: ",
    paste(dupes, collapse = ", "), "."
  )
  if (!is.null(exact)) stopifnot(
    "If 'exact' is specified, 'include' and 'exclude' must be NULL." =
      all(is.null(include), is.null(exclude))
  )

  g <- .filter_exclude_edges(g, exclude)

  if (!is.null(exact)) {
    g <- .filter_exact_edges(g, exact)
    .path_in_graph(exact, g, error = TRUE)
  }

  return(g)
}

#' @importFrom igraph induced_subgraph
#'
.filter_exclude_edges <- function(x, exclude) {
  # Only do work if exclude is not NULL
  if (is.null(exclude)) return(x)
  igraph::induced_subgraph(x, setdiff(.V_names(x), exclude))
}

#' @importFrom igraph V induced_subgraph
#'
.filter_exact_edges <- function(x, exact) {
  # Only do work if exclude is not NULL
  if (is.null(exact)) return(x)
  if (any(miss <- !exact %in% .V_names(x))) stop(
    "Elements of 'exact' not found: ",
    paste(.V_names(x)[miss], collapse = ", "), "."
  )
  igraph::induced_subgraph(x, exact)
}

#' @importFrom igraph as_ids V
#'
.V_names <- function(x) igraph::as_ids(igraph::V(x))

#' @importFrom igraph as_ids E
#'
.E_names <- function(x) igraph::as_ids(igraph::E(x))

.path_in_graph <- function(x, g, error = FALSE) {
  in_graph <- .V_path_as_E_path(x) %in% .E_names(g)

  if (error && !all(in_graph)) stop(
    "Defined path contains vertices not found in graph: '",
    paste(.V_path_as_E_path(x)[!in_graph], collapse = "', '"),
    "'."
  )
  return(all(in_graph))
}

.V_path_as_E_path <- function(x) vapply(
  seq_len(length(x) - 1L), function(i) paste0(x[i], "|", x[i + 1L]), ""
)


.shortest_path_include <- function(x, g, include) {
  head_term <- as.character(unique(x[[1L]]))
  tail_term <- as.character(unique(x[[2L]]))
  p_head <- .shortest_path_incl_head(g, include[[1L]], head_term)
  p_tail <- .shortest_path_incl_tail(g, include[[length(include)]], tail_term)
  if (length(include) == 1L) {
    res_path <- mapply(c, p_head, p_tail, SIMPLIFY = FALSE)
  } else {
    p_include <- .shortest_path_incl_multiples(g, include)
    res_path <- mapply(c, p_head, p_include, SIMPLIFY = FALSE)
    res_path <- mapply(c, res_path, p_tail, SIMPLIFY = FALSE)
  }
  return(res_path)
}

#' @importFrom igraph all_shortest_paths as_ids
.shortest_path_incl_head <- function(g, i, start_term) {
  lapply(
    igraph::all_shortest_paths(g, from = i, to = start_term)[["vpaths"]],
    function(x) rev(igraph::as_ids(x))
  )
}

#' @importFrom igraph all_shortest_paths as_ids
.shortest_path_incl_tail <- function(g, i, final_term) {
  lapply(
    igraph::all_shortest_paths(g, from = i, to = final_term)[["vpaths"]],
    function(x) igraph::as_ids(x)[-1L]
  )
}

#' @importFrom igraph all_shortest_paths as_ids
#'
.shortest_path_incl_multiples <- function(g, i) {
  inter_paths <- lapply(
    seq_len(length(i) - 1L),
    function(x) lapply(
      igraph::all_shortest_paths(
        g,
        from = i[[x]], to = i[[x + 1L]]
      )[["vpaths"]], function(y) igraph::as_ids(y)[-1L]
    )
  )
  res_path <- inter_paths[[1L]]
  for (p in seq_len(length(inter_paths) - 1L)) {
    res_path <- mapply(
      c, res_path, inter_paths[[p + 1L]],
      SIMPLIFY = FALSE
    )
  }
  return(res_path)
}


# Utilities ----


# Find a path through different feature types.
# returns a Character vector of the ids to walk in order.
#' @importFrom igraph shortest_paths graph_from_data_frame
#'
.term_seq <- function(terms, x) {
  stopifnot(
    "both terms must be found as colnames in 'x'" = all(
      terms %in% colnames(x)
    )
  )
  g <- igraph::graph_from_data_frame(
    d = .all_names_in_list_mf(x),
    directed = FALSE
  )
  sp <- igraph::all_shortest_paths(
    g,
    from = terms[1], to = terms[2]
  )
  names(unlist(sp, FALSE, FALSE)[[1]])
}

#' Find the order in which link data frames should be listed
#' @param term_list list of `Character vectors`, each with length of two.
#' @param d link@map.
#' @returns a numeric vector with order in which row data frames should be
#'     traversed.
#' @noRd
#'
.step_seq <- function(term_list, d) vapply(
  term_list,
  FUN = .rows_with_col,
  d = d,
  names = FALSE,
  FUN.VALUE = 0L,
  USE.NAMES = FALSE
)

#' @param d `multifactor@map`
#' @param id `Character or Integer scalar`. Selects column(s) of `d`.
#' @param names Whether to return characters (Default) or integer indices.
#' @returns A vector indicating which elements of `multifactor` contain `id`.
#' @importFrom Matrix rowSums
#' @noRd
#' @description Helper function for `multifactor` to get names or indices of
#' data frames that contain an id column
#'
.rows_with_col <- function(d, id, names = TRUE) {
  rowInds <- which(Matrix::rowSums(d[, id, drop = FALSE] != 0L) == length(id))
  if (length(rowInds) == 0L) {
    return(0L)
  }
  if (names) {
    rowInds <- rownames(d)[rowInds]
  }
  return(rowInds)
}

.subset_by_path <- function(link, all_terms) {
  term_list <- lapply(
    seq_len(length(all_terms) - 1L),
    FUN = function(x) all_terms[c(x, x + 1L)]
  )
  steps <- .step_seq(term_list, link@map)
  link <- link[steps]
  return(link)
}
