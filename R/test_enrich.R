#' Perform enrichtment tests on relational data
#' @importFrom S7 S7_inherits
#' @importFrom stats p.adjust
#' @param x A linkmap with coverage metadata from `weave_coverage()`.
#' @param log_base `Integer`. Base of logarithm for log-fold (default: 2).
#' @rdname test_enrich-methods
#' @name test_enrich-methods
#'
NULL

method(test_enrich, multifactor) <- function(
        x, .path, .data = NULL,
        .data_column = "row.names",
        log_base = 2L,
        method = list(fisher = c(alternative = "greater"))
) {
    x <- weave_coverage(
        x, .path, .data,
        c("set_count", "set_size", "coverage", "complete"),
        "linkmap",
        .data.column
        )

    .test_enrich.linkmap(
        x = x, .path = .path, .data = .data, .data_column = .data_column,
        log_base = log_base, method = method
        )
}


S7::method(test_enrich, linkmap) <- function(
        x, .path = formula(x), .data = NULL,
        .data_column = "row.names",
        log_base = 2L,
        method = list(fisher = c(alternative = "greater"))
).test_enrich.linkmap(x, .path, .data, .data_column, log_base, method)


.test_enrich.linkmap <- function(
        x, .path = formula(x), .data = NULL,
        .data_column = "row.names",
        log_base = 2L,
        method = list(fisher = c(alternative = "greater"))
) {

    if(!all(c("observed", "set_count", "set_size") %in% colnames(x@metadata))) {
        .tempdata <- .data_coverage_to_vector(.data, .data_column)
        x <- .coverage_single_step(
            x, all.vars(.path), .tempdata,
            c("set_count", "set_size", "coverage", "complete")
        )
    }

    i <- stats::reformulate(colnames(x)[[2L]])
    mm <- as.data.frame(x)

    # q = actual hits, m = possible hits, n = possible misses, k = n_draws
    q <- tapply(mm, i, function(xx) max(0, unique(xx[["set_count"]])))
    m <- tapply(mm, i, function(xx) max(0, unique(xx[["set_size"]])))
    n <- nlevels(mm[[1L]]) - unlist(m)
    k <- length(unique(mm[mm[["observed"]], 1L]))

    cont_df <- data.frame(q, m, n, k)

    expected <- k / (m + n)
    observed <- q / m
    fold <- observed / expected
    log_fold <- log(fold, log_base)

    p.value <- switch(
        names(method),
           fisher = .enrich_test_fisher(q, m, n, k, method[["fisher"]])
    )
    p.adj <- stats::p.adjust(p.value, method = "BH")

    res <- data.frame(expected, observed, fold, log_fold, p.value, p.adj)

    return(res)
}



#' @importFrom stats phyper
.enrich_test_fisher <- function(q, m, n, k, method) {
    alt <- match.arg(method[["alternative"]], c("greater", "less"))
    p <- switch(
        alt,
        greater   = phyper(q -1L, m, n, k, lower.tail = FALSE ),
        less      = phyper(q, m, n, k, lower.tail = TRUE )
    )
    p
}

