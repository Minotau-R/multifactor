# library(ggplot2)
# library(ggforce)
# library(tidyr)
# library(tidyverse)
# library(ggraph)
# library(tidygraph)
#
#
# x <- quickbrownfox()
#
# .mf_as_long <- function(x) bind_rows(
#     lapply(
#         S7::S7_data(x),
#         function(i) dplyr::reframe(
#             as.data.frame(i),
#             from = i[[1L]], to = i[[2L]],
#             from_y = as.integer(from), to_y = as.integer(to)
#         )
#     ) ,
#     .id = "linkmap"
# )
#
#
#
# df <- .mf_as_long(x) |>
#
#     separate_wider_delim(
#         linkmap, delim = "2", names = c("from_name", "to_name"),
#         ) |>
#     #distinct(from_name, to_name, from_y, .keep_all = TRUE) |>
#     mutate(
#         from_y = case_when(
#             from_name == "letter" ~ from_y * -1,
#             from_name == "word" ~ unique(sort(from_y, decreasing = TRUE))[match(
#                 from,
#                 c("the", "quick", "brown", "fox", "jumps", "over",  "lazy", "dog")
#             )],
#             .default = from_y
#         ), .by = c(from_name, to_name)
#         ) |>
#     mutate(
#         from_y = (from_y - mean(unique(from_y))) *
#             (length(letters) / length(unique(from))),
#         to_y = (to_y - mean(unique(to_y))) *
#             (length(letters) / length(unique(to))),
#         .by = c(from_name, to_name)
#     ) |>
#
#     pivot_longer(c(from, to)) |>
#
#
#     mutate(
#         from_name = factor(
#             from_name,
#             levels = c("letter", "word", "constituent", "sentence")
#         ),
#         to_name = factor(
#             to_name,
#             levels = c("letter", "word", "constituent", "sentence")
#         )
#     ) |> mutate(
#         value = value |>
#             str_replace("brown fox", "brown\nfox") |>
#             #str_replace(value, "brown fox jumps", "fox\njumps") |>
#             #str_replace(value, "fox jumps", "fox\njumps"
#             str_replace("over the", "over\nthe")
#         ,
#         from_x = case_when(
#             from_name == "letter" ~ 0,
#             from_name == "word" ~ 1.5,
#             from_name == "constituent" ~ 2.5,
#             from_name == "sentence" ~ 3.5
#             ),
#         to_x = case_when(
#             to_name == "letter" ~ 0,
#             to_name == "word" ~ 1.5,
#             to_name == "constituent" ~ 2.5,
#             to_name == "sentence" ~ 3.5
#         )
#
#     )
#
#
#  p <-    ggplot() +
#
#         ggforce::geom_link(
#             data = filter(df, from_name != "letter"),
#             aes(x = from_x, xend = to_x,
#                 y = from_y, yend = to_y),
#             linewidth = 2,
#             show.legend = FALSE
#         ) +
#         ggforce::geom_link(
#             data = filter(df, from_name != "letter"),
#             aes(x = from_x, xend = to_x,
#                 y = from_y, yend = to_y),
#             linewidth = 1, colour = "white",
#             show.legend = FALSE
#         ) +
#
#         ggforce::geom_diagonal(
#             data = filter(df, from_name == "letter"),
#             aes(x = from_x, xend = to_x,
#                 y = from_y, yend = to_y),
#             linewidth = 2,
#             show.legend = FALSE
#         ) +
#         ggforce::geom_diagonal(
#             data = filter(df, from_name == "letter"),
#             aes(x = from_x, xend = to_x,
#                 y = from_y, yend = to_y, colour = from_y),
#             linewidth = 1,
#             show.legend = FALSE
#         ) +
#
#         # NODES
#         # geom_point(
#         #     data = filter(df, name == "from" & from_name == "letter"),
#         #     aes(x = from_x, y = from_y, fill = from_y),
#         #     show.legend = FALSE, size = 12, shape = 22, stroke = 11/10,
#         # ) +
#      geom_label(
#          data = filter(df, name == "from" & from_name == "letter"),
#          aes(x = from_x, y = from_y, fill = from_y), label = "     ",
#          show.legend = FALSE, size = 6, linewidth = 4/5
#      ) +
#         geom_text(
#             data = filter(df, name == "from" & from_name == "letter"),
#             aes(x = from_x, y = from_y, label = value),
#             show.legend = FALSE, size = 6
#         ) +
#
#         geom_label(
#             data = filter(df, name == "from" & from_name != "letter"),
#             aes(x = from_x, y = from_y, label = value),
#             show.legend = FALSE,
#             size = 6, fill = "white", linewidth = 4/5
#             ) +
#         geom_label(
#             data = filter(df, to_name == "sentence"),
#             aes(x = to_x, y = to_y, label = value),
#             show.legend = FALSE,
#             size = 6, fill = "white", linewidth = 4/5
#         ) +
#
#         annotate(
#             geom = "text", y = - 14, x = c(0, 1.5, 2.5, 3.5),
#             label = c("letter", "word", "constituent", "sentence"), size = 8
#             ) +
#         scale_colour_gradient(
#             aesthetics = c("colour", "fill"),
#             low = "dodgerblue",  high = "orange"
#             ) +
#         scale_x_continuous(expand = expansion(0, 1)) +
#
#         theme_void()
#
#
#  pngfile <- file.path("images", "fox-enrichment.png")
#  pngfile <- file.path("vignettes", "images", "fox-enrichment.png")
#  ggsave(pngfile, p, device = ragg::agg_png, height = 10, width = 10)
#
#
