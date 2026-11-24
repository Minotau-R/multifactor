method(`%*%`, list(linkmap, linkmap)) <- function(x, y) {
    term_list <- .weaveops_get_terms(x, y)
    res <- Matrix::`%&%`(
        `as.matrix.multifactor::linkmap`(x, term_list[[1]]),
        `as.matrix.multifactor::linkmap`(y, term_list[[2]])
    )
    res <- as_linkmap(res)
    levels(res) <- c(
        levels(x)[term_list[[1L]][1L]],
        levels(y)[term_list[[2L]][2L]]
        )
    res
}

.weaveops_get_terms <- function(x, y) {
    cn1 <- colnames(x)
    cn2 <- colnames(y)
    mid <- intersect(cn1, cn2)
    stopifnot(
        "linkmaps must have one column name in common." = length(mid) == 1L
    )
    list(
        c(setdiff(cn1, mid), mid),
        c(mid, setdiff(cn2, mid))
    )
}
