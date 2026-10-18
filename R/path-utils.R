#' path_frame utilities
#' @noRd
#' @examples
#' x <- random_multifactor()
#' .path <- a ~ b:c > 0.2 ~ d + e:f ~ g
#' pf <- as_path_frame(.path)
#'
NULL

.deparse_fm <- function(x) paste0(deparse(x, 500L), collapse = "")

.check_path_frame_is_minimal <- function(.pf) NROW(.pf) == 1L

.check_path_frame_uses_stack <- function(.pf) any(.pf[["stack"]])

.check_path_frame_uses_coverage <- function(.pf) any(.uses_coverage_bool(.pf))

.uses_coverage_bool <-
  function(x) !(x[["cov_operator"]] == ">=" & x[["cov_value"]] == 0)

.is_colon_shorthand <-
  function(x) x[["cov_operator"]] %in% c(">=", "==") & x[["cov_value"]] == 1

.valid_path_input <- function(.path) {
  classes <- c("character", "formula", "data.frame", "list")
  # Some grace for select_path output
  if (is.list(.path) && length(.path) == 1L) {
    .path <- .path[[1L]]
  }
  stopifnot(
    "'.path' must be a formula or a (list of) character vector(s)." =
      inherits(.path, classes)
  )
  invisible()
}


.path_to_path_frame_df <- function(.path) {
    .path <- .standardize_path_to_fm(.path)
    res <- .cut_fm_to_df(.path)
    res
}

#' @importFrom stats as.formula
#'
.standardize_path_to_fm <- function(.path) {
    .valid_path_input(.path)

    # Some flexibility if input is in a list of length 1:
    if (is.list(.path) && length(.path) == 1L) {
        .path <- .path[[1L]]
    }
    if (inherits(.path, "character")) {
        .path <- stats::as.formula(paste0(.path, collapse = "~"))
    }
    .path
}

.cut_fm_to_df <- function(x, all_seps = c("~", ":")) {
  # Convert to character
  x <- .deparse_fm(x)

  all_seps <- paste0(all_seps, collapse = "|")

  # Get all separators and content
  seps <- strsplit(gsub(paste0("[^", all_seps, "]"), "", x), "")[[1L]]
  content <- .drop_trailing_spaces(strsplit(x, all_seps)[[1L]])
  full_cov <- seps == ":"
  cov_res <- .parse_coverage(content, full_cov)
  cov_operator <- cov_res[["cov_operator"]]
  cov_value    <- cov_res[["cov_value"]]
  content <- cov_res[["content"]]

  from <- factor(content[seq_along(seps)], unique(sort(content)))
  to <- factor(content[seq_along(seps) + 1L], unique(sort(content)))

  stack <- grepl("+", to, fixed = TRUE) | grepl("+", from, fixed = TRUE)

  data.frame(from, to, cov_operator, cov_value, stack)
}

.pf_as_full_path_list <- function(x) unname(
  tapply(x, ~components, `terms.multifactor::path_frame`, simplify = FALSE)
)

.parse_coverage <- function(content, full_cov) {
  # Fill in required coverage thresholds
  # `:` colon is shorthand for full coverage:
  cov_req <- vector("character", length = length(full_cov))
  cov_req[full_cov] <- ">= 1"

  if (!all(full_cov)) {
    all_ops <- c(">", "<", ">=", "<=", "==", "!=")
    ops <- paste0(all_ops, collapse = "|")

    # t_cov is an index of coverage values with a specified threshold
    t_cov <- grepl(paste0("[", ops, "]"), content[-1L]) & !full_cov

    cov_req[!full_cov & !t_cov] <- ">= 0"

    if (any(t_cov)) {
      cov_req[t_cov] <- .drop_trailing_spaces(
        sub(
          paste0("^([^", ops, "])"),
          "",
          content[-1L],
          perl = TRUE
        )[t_cov]
      )
      content[-1L][t_cov] <- .drop_trailing_spaces(
        gsub(
          paste0("[", ops, "].*"), "",
          content[-1L],
          perl = TRUE
        )[t_cov]
      )
    }
  }

  list(
    cov_operator = gsub(paste0("[^", ops, "]"), "", cov_req),
    cov_value = as.numeric(gsub(".* ", "", cov_req)),
    content = content
  )
}

.drop_trailing_spaces <- function(x) gsub("^ | $", "", x)
