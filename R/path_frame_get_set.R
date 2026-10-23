.get_path_terms.pf <- function(.pf, i) `terms.multifactor::path_frame`(.pf)


.set_path_terms.pf <- function(.pf, value) {
    i_max <- NROW(.pf) + 1L
    i <- seq_len(i_max)
    stopifnot(
        "Replacement values must exist as levels." = all(value %in% terms(.pf))
    )

    .pf[["from"]][i[i != i_max]]  <- value[i != i_max]
    .pf[["to"]][i[i != 1L] -1L]   <- value[i[i != 1L]]

    .pf
}


.get_path_links.pf <- function(.pf) {
    apply(
        .pf, 1L, FUN = function(x) {
            formula(
                paste(
                    x[["from"]], "~", x[["to"]],
                    x[["cov_operator"]], x[["cov_value"]]), globalenv()
            )
        }, simplify = FALSE
    )
}

#' @importFrom rlang f_lhs f_rhs
.set_path_links.pf <- function(.pf, value) {

    if( !is.list(value) ) value <- list(value)
    i <- seq_along(value)
    value <- lapply(value, formula)

    stopifnot(
        "Replacement values must exist as levels." = all(
            unlist( lapply(value, all.vars) ) %in% terms(.pf)
        )
    )

    .pf[["from"]][i] <- vapply(value, function(x) deparse1(rlang::f_lhs(x)), "")
    rhs <- vapply(value, function(x) deparse1(rlang::f_rhs(x)), "")

    .pf[["to"]][i]   <- .get_rhs_no_expr_str(rhs)

    cov_op <- .get_rhs_expr_str(rhs)
    cov_op[cov_op == ""] <- ">= 0"

    .pf[["cov_operator"]][i] <- sub(" .*", "", cov_op)
    .pf[["cov_value"]][i] <- as.numeric(sub(".* ", "", cov_op))

    .pf
}


.get_rhs_expr_str <- function(rhs) .drop_trailing_spaces(
    sub(
        paste0(
            "^([^",
            paste0(c(">", "<", ">=", "<=", "==", "!="), collapse = "|"),
            "])"
        ),
        "",
        rhs,
        perl = TRUE
    )
)


.get_rhs_no_expr_str <- function(rhs) .drop_trailing_spaces(
    sub(
        paste0(
            "[",
            paste0(c(">", "<", ">=", "<=", "==", "!="), collapse = "|"),
            "].*"
        ),
        "",
        rhs,
        perl = TRUE
    )
)

