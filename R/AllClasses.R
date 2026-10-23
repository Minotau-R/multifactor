#' linkmap S7 container class
#' @name linkmap
#' @rdname linkmap-class
#' @description
#' `linkmap` is an S7 class to organize and manage multiple sets of factors,
#' for instance when tracing or converting feature IDs across databases. Methods
#' for `linkmap` aim to follow `factor` behaviour.
#'
#' @slot levels `Named list` of character vectors depicting levels.
#' @slot metadata `data.frame`. Optional. Used to store additional data or
#'     application-specific tags.
#' @param x `data.frame` with two named columns that can be coerced to factors.
#'     Optionally, additional columns will be stored as metadata.
#' @param metadata Optional `data.frame` with same number of rows as x. Contains
#'     information about the feature link in that row.
#' @returns a `linkmap` object.
#' @examples
#' # Generate random linkage input
#' x <- data.frame(
#'   a = sample(letters[seq(3)], 10, replace = TRUE),
#'   A = sample(LETTERS[seq(3)], 10, replace = TRUE)
#' )
#'
#' # Create linkmap
#' linkmap(x)
#'
#' @seealso [multifactor()]
#' @importFrom forcats as_factor
#' @export
#'
linkmap <- S7::new_class(
  "linkmap",
  package = "multifactor",
  parent = S7::class_data.frame,
  properties = list(
    levels = S7::new_property(
      getter = function(self) lapply(S7::S7_data(self), levels),
      setter = function(self, value) {
        x <- `class<-`(S7::S7_data(self), "data.frame")
        S7::S7_data(self) <- .unify_levels_linkmap(x, value)
        return(self)
      }
    ),
    metadata = S7::new_property(
      class = S7::class_data.frame,
      getter = function(self) self@metadata
    )
  ),
  constructor = function(x, metadata = NULL) {
    # Check input
    stopifnot(.check_input_df(x))

    if (S7::S7_inherits(x, linkmap)) {
      if (!NCOL(metadata)) {
        metadata <- x@metadata
      }
      x <- `class<-`(S7::S7_data(x), "data.frame")
    }
    if (!NCOL(metadata)) {
      metadata <- data.frame(row.names = seq_len(NROW(x)))
    } else {
      stopifnot(
        "Arg 'x' must have the same number of rows as 'metadata'" =
          NROW(x) == NROW(metadata)
      )
    }
    # Factorize x, preserve order
    x[] <- lapply(x, forcats::as_factor)
    i <- !duplicated(x)
    x <- x[i, , drop = FALSE]
    x <- `row.names<-.data.frame`(x, NULL)
    metadata <- metadata[i, , drop = FALSE]
    metadata <- `row.names<-.data.frame`(metadata, NULL)
    S7::new_object(x, metadata = metadata)
  },
  validator = function(self) {
    if (!is.data.frame(self)) {
      "Must be a data.frame."
    }
    if (NCOL(self) != 2L) {
      "Must be a data.frame with two columns."
    }
    if (length(colnames(self)) != 2L) {
      "Both columns must be named."
    }
    if (!all(vapply(self, is.factor, NA, USE.NAMES = FALSE))) {
      "Both columns must be factors."
    }
  }
)


#' multifactor S7 container class
#' @name multifactor
#' @rdname multifactor-class
#' @description
#' `multifactor` is an S7 class to organize and manage multiple sets of factors,
#' for instance when tracing or converting feature IDs across databases. Methods
#' for `multifactor` aim to follow `factor` behaviour.
#'
#' @details
#' The most straightforward way to construct a `multifactor` object is as a
#' named list of named data.frames. The columns of the data.frames indicate the
#' category of factor in that column.
#'
#' A `multifactor` object presents itself similar to a `data.frame`, in the
#' sense that level types can be called as columns and individual data.frame
#' components can be called as rows.
#' `multifactor` inherits from `list`; Content can be accessed through regular
#' list methods (e.g., `[`, `[[`).
#' @slot levels `Named list of character vectors`. Accessed through `levels(x)`
#' @slot map `(sparse) Matrix` specifying which elements contain which levels.
#' @param x a `linkmap`, or named list of `linkmap` objects.
#' @param levels Optional. A `named list of character vectors`, to be used as
#'     levels.
#' @returns a `multifactor` object.
#' @seealso [multifactor-methods()]
#' @importFrom S7 new_class new_property
#' @examples
#' # Generate some random linkage input
#' a2b <- data.frame(
#'   a = sample(letters[seq(3)], 10, replace = TRUE),
#'   b = sample(LETTERS[seq(3)], 10, replace = TRUE)
#' )
#' a2c <- data.frame(
#'   a = sample(letters[seq(3)], 10, replace = TRUE),
#'   c = sample(LETTERS[seq(3)], 10, replace = TRUE)
#' )
#' x <- multifactor(list(a2b, a2c))
#'
#' @seealso [linkmap()]
#' @export
#'
multifactor <- S7::new_class(
  "multifactor",
  package = "multifactor",
  parent = S7::class_list,
  properties = list(
    levels = S7::new_property(
      class = S7::class_list,
      getter = function(self) self@levels,
      setter = function(self, value) {
        # If initializing, don't re-unify
        if (!length(levels(self))) {
          self@levels <- value
        } else {
          self <- .set_levels_multifactor(self, value)
        }
        return(self)
      }
    ),
    map = S7::new_property(
      getter = function(self) .map_multifactor(self, mode = "counts")
    ),
    metadata = S7::new_property(
      getter = function(self) Reduce(
        function(...) merge(..., all = TRUE), lapply(self, .squash_meta)
      )
    )
  ),
  constructor = function(x, levels = list()) {
    # Check input
    if (is.data.frame(x)) x <- linkmap(x)
    if (S7::S7_inherits(x, linkmap)) x <- list(x = x)
    stopifnot(
      "x must be a linkmap or list of linkmaps. " =
        all(vapply(x, .check_input_df, FALSE))
    )
    x <- lapply(x, linkmap)
    # In case of identical pair names, merge.
    names(x) <- paste0("x_", seq_along(x))
    x <- .merge_linkmaps(x)

    if (!length(levels)) levels <- .build_levels_from_lm_list(x)
    x <- .unify_levels(x, levels)

    names(x) <- vapply(x, .linkmap2name, FUN.VALUE = "", USE.NAMES = FALSE)

    S7::new_object(
      x,
      levels = levels
    )
  },
  validator = function(self) {
    if (!all(vapply(self, .valid_linkmap, NA))) {
      "linkmap content not properly formatted. "
    }
  }
)


#' path_frame S7 class
#' @name path_frame
#' @rdname path_frame-class
#' @description
#' `path_frame` is an S7 class to standardize the various ways in which paths
#' that can be specified across the `multifactor` package. This class is mostly
#' for internal use.
#' @param x `data.frame` with the first two columns named `"from"` and `"to"`.
#'     Optionally, additional columns (see Details)
#' @param call `character` (Default: empty). If Input is a formula, captures the
#'     literal content as a character string.
#' @prop `terms` `Character vector` of names of the steps in order.
#' @prop `links` `List of formulas`, each representing one step in the path.
#' @details
#' Rows represent edges in a path. Additional (optional) columns contain
#' information about the edges:
#' \itemize{
#'   \item `components` `integer`. Indicates subpath ID.
#'   \item `stack` `logical`. Whether the vertex contains merged data types.
#'   \item `coverage` `numeric`. The proportional coverage threshold (or 0).
#' }
#' @returns a `path_frame` object.
#' @importFrom S7 new_class new_property class_character new_object
#' @examples
#' path_frame
#'
#' @export
#'
path_frame <- S7::new_class(
  "path_frame",
  package = "multifactor",
  parent = S7::class_data.frame,
  properties = list(
    call = S7::new_property(
      class = S7::class_character,
      getter = function(self) S7::prop(self, "call"),
      default = character()
    ),
    terms = S7::new_property(
      class = S7::class_character,
      getter = function(self) .get_path_terms.pf(self),
      setter = function(self, value) .set_path_terms.pf(self, value)
    ),
    links = S7::new_property(
      class = S7::class_list,
      getter = function(self) .get_path_links.pf(self),
      setter = function(self, value) .set_path_links.pf(self, value)
    )
  ),
  constructor = function(x, call = character()) {
    stopifnot("path_frame input must be a data.frame." = is.data.frame(x))
    S7::new_object(.parent = x, call = call)
  },
  validator = function(self) {
    if (!all(colnames(self)[seq_len(2L)] == c("from", "to"))) {
      "First two path_frame columns must be named 'from' and 'to'."
    }
  }
)


##### linkmap utils --]--

.check_input_df <- function(x) {
  if (!is.data.frame(x)) {
    stop("Must be a data.frame. ")
  }
  if (!NCOL(x) == 2L) {
    stop("Must be a data.frame with at least two key columns. ")
  }
  if (!length(colnames(x)) == 2L) {
    stop("Both key columns must be named. ")
  }
  return(TRUE)
}


#### multifactor utils ----

.squash_meta <- function(x) {
  names <- paste(colnames(x), collapse = "2")
  res <- lapply(x@metadata, unique)
  mult <- lengths(res) > 1L
  res[mult] <- lengths(res)[mult]

  res <- c(name = names, res)
  `class<-`(`attr<-`(res, "row.names", names), "data.frame")
}

.map_multifactor <- function(x, mode = "counts") {
  # Some flexibility in input
  mode <- match.arg(mode, choices = c("counts", "binary", "pattern"))
  all_names <- lapply(x, base::names)
  i <- factor(
    rep(names(all_names), lengths(all_names, use.names = FALSE)),
    levels = names(all_names)
  )
  j <- factor(
    unlist(all_names, use.names = FALSE),
    levels = unique(unlist(all_names, use.names = FALSE))
  )

  # mx is a vector of length i that determines the values of sparse Matrix.
  mx <- switch(mode,
    "counts" = unlist(
      lapply(x, function(y) {
        lapply(y, function(z) length(unique(z)))
      }),
      use.names = FALSE
    ),
    "binary" = 1L,
    "pattern" = TRUE
  )

  return(
    Matrix::sparseMatrix(
      i = i,
      j = j,
      x = mx,
      dimnames = list(
        levels(i),
        levels(j)
      )
    )
  )
}


.merge_linkmaps <- function(x) {
  all_names <- lapply(x, function(x) sort(names(x)))
  if (!any(duplicated(all_names))) return(x)

  dup_names <- unique(all_names[duplicated(all_names)])
  merg_list <- vector("list", length = length(dup_names))

  for (dup in seq_along(dup_names)) {
    merg <- unique(do.call(rbind, x[all_names %in% dup_names[dup]]))
    row.names(merg) <- NULL
    merg[] <- lapply(merg, \(x) forcats::lvls_reorder(x, order(levels(x))))

    merg_list[[dup]] <- merg
  }
  names(merg) <- lapply(dup_names, paste0, collapse = "2")
  x <- c(x[!all_names %in% dup_names], merg_list)
  return(x)
}

#' @noRd
#' @param x a list in `multifactor` formatting.
#' @description Drop features that are not matched in another linkmap.
#' @returns a subsetted list with `multifactor`.formatting.
#' @importFrom Matrix colSums
#'
.trim_multifactor <- function(x) {
  # Determine positions of feature names that occur in several edge link dfs
  m <- .map_multifactor(x, mode = "pattern")
  jj <- colnames(m)[Matrix::colSums(m) > 1]

  # Sequentially subset over feature names
  for (j in jj) {
    # Select all those data frames where that term is mentioned
    ii <- .rows_with_col(m, j, FALSE)
    keep <- Reduce(intersect, lapply(x[ii], base::`[[`, j))

    # Filter feature ids in each df to only universally shared ones.
    x[ii] <- lapply(x[ii], function(df) {
      return(df[df[[j]] %in% keep])
    })
  }
  return(x)
}

#' @description Subset multifactor to only include the features
#'     found in a feature table.
#' @returns a multifactor subsetted by relevant features
#' @param x a `multifactor` .
#' @param id `Character scalar`, naming the x term to be trimmed
#' @param ft A table containing features of interest, `tableX` or `tableY`.
#' @noRd
#'
.trim_by_feature_table <- function(x, ft, id) {
  lv <- levels(x)[[id]]
  r <- .rows_with_col(x@map, id)
  stopifnot(
    "Feature names appeared in several index elements. " = length(r) == 1L
  )
  # Subset index by table rows
  xr <- x[[r]]
  x.names <- match(row.names(ft), lv)
  xr <- xr[xr[, id] %in% x.names, ]
  xr.id <- xr[, id]

  # Subset levels
  x@levels[[id]] <- lv[sort(unique(xr.id))]
  # Reorder and replace indices
  xr[, id] <- match(xr.id, sort(unique(xr.id)))
  x[[r]] <- xr

  return(x)
}

#' Given a list of linkmaps x, return a unified and sorted list of levels.
#' @noRd
.build_levels_from_df_list <- function(x) {
  all_lvs <- unique(unlist(lapply(x, colnames), FALSE, FALSE))
  lvs <- .gather_all_levels(x, all_lvs)
  return(lvs)
}

#' Given a list of linkmaps x, return a unified and sorted list of levels.
#' @noRd
.build_levels_from_lm_list <- function(x) {
  all_lvs <- unique(unlist(lapply(x, colnames), FALSE, FALSE))
  lvs <- .gather_all_levels(x, all_lvs)
  return(lvs)
}

#' @importFrom forcats lvls_union
#' @noRd
#'
.gather_all_levels <- function(x, levels) {
  res <- lapply(
    levels,
    function(lv) {
      fct_in <- lapply(x, `[[`, lv)
      fct_in <- fct_in[!vapply(fct_in, is.null, FUN.VALUE = TRUE)]
      res <- forcats::lvls_union(fct_in)
      sort(res)
    }
  )
  names(res) <- levels
  return(res)
}

#' Given a list of linkmaps x and named list of chars levels, unify all levels
#' across x.
#' @noRd
.unify_levels <- function(x, levels) {
  is_s7 <- all(vapply(x, S7::S7_inherits, linkmap, FUN.VALUE = FALSE))
  if (is_s7) {
    res <- lapply(x, .unify_levels_linkmap, levels)
  } else {
    res <- lapply(x, .unify_levels_data.frame, levels)
  }
  return(res)
}

#' @importFrom forcats lvls_expand
#'
.unify_levels_data.frame <- function(x, levels) {
  x <- mapply(
    forcats::lvls_expand, x,
    levels,
    SIMPLIFY = FALSE
  )
  return(x)
}


# TODO metadata and .data are now separate props. Use lapply for indexing?
# FIXME
#' @importFrom forcats lvls_expand
#'
.unify_levels_linkmap <- function(x, levels) {
  x[] <- mapply(
    forcats::lvls_expand,
    x,
    levels[colnames(x)],
    SIMPLIFY = FALSE
  )
  # S7::S7_data(x) <- `class<-`(old, "data.frame")
  return(x)
}

.valid_linkmap <- function(x) {
  is.data.frame(x) &&
    NCOL(x) == 2L &&
    length(colnames(x)) == 2L &&
    all(vapply(x, is.factor, NA, USE.NAMES = FALSE))
}
