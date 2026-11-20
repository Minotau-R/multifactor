#' @import S7
#' @rawNamespace if (getRversion() < "4.3.0") importFrom("S7", "@")
NULL

.onLoad <- function(...) {
    S7::S7_on_load()
}
.onUnload <- function(...) {
    S7::S7_on_unload()
}
S7::S7_on_build()
