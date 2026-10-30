#' Join linkmaps across a path
#' @name weave_join
#' @rdname weave_join
#' @description Generates a data.frame by combining all columns across linkmaps
#'     in a path.
#' @param x a `multifactor`
#' @param .path Either a `formula` or a `character vector` of length 2 with the
#'     names of the desired combination of feature types.
#' @param metadata `Boolean` Whether to include all metadata within the
#'     linkmaps or just the factor columns (Default).
#' @param sort `Boolean`. Should the result be sorted by factor level?
#' @param simplify `Boolean`. Should the returned object be coerced to a
#'     `data.frame`, or should the raw list be returned?
#' @returns a `data.frame`
#' @examples
#' # Use the quick brown fox pangram dataset from the vignette
#' fox <- quickbrownfox()
#' weave_join(fox, letter ~ sentence)
#'
#' # If there are multiple paths, the result is bound to a single data.frame
#' set.seed(2612)
#' tp <- trade_posts()
#' weave_join(tp, fruit ~ clothing)
#'
#' # Set 'simplify' to 'FALSE' to instead the unmerged data.frames in a list.
#' weave_join(tp, fruit ~ clothing, simplify = FALSE)
#'
#' @importFrom dplyr relocate bind_rows
#' @export
#'
weave_join <- function(
        x, .path, metadata = FALSE, sort = TRUE, simplify = TRUE
        ) {
    stopifnot("'x' must be a multifactor." = S7::S7_inherits(x, multifactor))
    .valid_path_input(.path)
    pf <- as_path_frame(.path)
    .path_check_valid_weave_join(pf)

    pf <- .select_enframe_path(x, pf)

    full_path <- .pf_as_full_path_list(pf)
    res <- lapply(
        full_path, .weave_join_full_path,
        x = x, metadata = metadata, sort = sort
        )

    if(simplify) {
        if(length(res) == 1L) {
            res <- res[[1L]]
        } else {
            res <- dplyr::relocate(
                dplyr::bind_rows(res, .id = "component"),
                pf[NROW(pf), "to"],
                .after = 1 + length(unique(unlist(full_path)))
                )
        }
    }
    res
}

.weave_join_full_path <- function(all_terms, x, metadata, sort) {
    x <- .subset_by_path(x, all_terms)
    terms <- all_terms[c(1L, length(all_terms))]
    term_list <- lapply(
        seq_len(length(all_terms) - 1L),
        FUN = function(x) all_terms[c(x, x + 1L)]
    )
    steps <- .step_seq(term_list, x@map)

    # Extract linkmaps in order
    i <- S7::S7_data(x)[steps]
    if(metadata) {
        i <- lapply(i, as.data.frame)
    } else {
        i <- lapply(i, S7::S7_data)
    }
    res <- Reduce(function(...) merge(..., sort = FALSE), i)
    # Correct column order, metadata last, if any
    res <- res[, c(all_terms, setdiff(colnames(res), all_terms))]
    if(sort) {
        res <- res[do.call(order, lapply(res[all_terms], as.integer)), ]
    }
    rownames(res) <- NULL
    res
}



.path_check_valid_weave_join <- function(x) {
    if (.check_path_frame_uses_stack(x)) {
        stop(
            "`weave_join()` '.path' cannot contain '+'. ",
            "Use `stack()` to prepare input."
        )
    }
}
