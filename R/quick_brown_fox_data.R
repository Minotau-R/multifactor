#' @importFrom utils data
.load_quickbrownfox <- function() local({
  utils::data("quickbrownfox", package = "multifactor", envir = environment())
  quickbrownfox <- get("quickbrownfox", mode = "list")
  return(quickbrownfox)
})

#' A multifactor containing a famous pangram.
#' @description
#' Demo data set used in the coverage en enrichment vignette.
#' @name quickbrownfox
#' @param raw.data `Boolean`, Whether to return underlying `list` rather
#' than the default `multifactor`.
#' @export
#' @examples
#' quickbrownfox()
#'
quickbrownfox <- function(raw.data = FALSE) {
  x <- .load_quickbrownfox()
  if (!raw.data) {
    x <- multifactor(x)
  }
  return(x)
}




# Define components
#
# sentence <- "the quick brown fox jumps over the lazy dog"
# letter <- letters
#
# word <- strsplit(sentence, split = " ", fixed = TRUE)[[1]]
# word_lv <- unique(word)
#
# constituent <- c("the quick brown fox", "jumps over", "the lazy dog")
# constituent_lv <- c("subject", "predicate", "object")
#
# # Compile linkmaps
#
# letter2word <- lapply(word, strsplit, split = "", fixed = FALSE) |>
#     unlist(recursive = FALSE) |>
#     `names<-`(word) |>
#     stack() |>
#     `colnames<-`(c("letter", "word"))
#
#
#
# word2constituent <- lapply(constituent, strsplit, split = " ", fixed = FALSE) |>
#     unlist(recursive = FALSE) |>
#     `names<-`(c("subject", "predicate", "object")) |>
#     stack() |>
#     `colnames<-`(c("word", "constituent"))
#
# constituent2sentence <- data.frame(
#     constituent = c("subject", "predicate", "object"),
#     sentence    = sentence
# )
#
# quickbrownfox <- list(letter2word, word2constituent, constituent2sentence)
#
# save(quickbrownfox, file = "data/quickbrownfox.rda")

