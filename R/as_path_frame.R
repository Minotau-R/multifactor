S7::method(as_path_frame, S7::class_character) <- function(x) {
    x <- stats::as.formula(paste0(x, collapse = "~"))
    call <- .deparse_fm(x)
    x <- .path_to_path_frame_df(x)
    path_frame(x, call)
}

S7::method(as_path_frame, S7::class_formula) <- function(x) {
    call <- .deparse_fm(x)
    x <- .path_to_path_frame_df(x)
    path_frame(x, call)
}

S7::method(as_path_frame, path_frame) <- function(x) x

S7::method(as_path_frame, S7::class_data.frame) <-
    function(x, call = "") path_frame(x, call)
