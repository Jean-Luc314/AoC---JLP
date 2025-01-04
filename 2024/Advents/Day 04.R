library(tidyverse)
source("helpers/helpers.R")

input <- input_read_lines("2024", "04")
input <- input_read_lines_example("2024", "04")

wordsearch <- input |> str_split("") |> (\(chr) do.call(rbind, chr))()

collapse <- function(chr) paste(chr, collapse = "")

str_reverse <- function(str) {
  str |>
    str_split_1("") |>
    rev() |>
    collapse()
}

search_string <- function(str, word = "XMAS") str_count(str, word) + str_count(str, str_reverse(word))



nrow <- dim(wordsearch)[[1]]
ncol <- dim(wordsearch)[[2]]
i <- seq(nrow)
j <- rep(1, ncol)
# Need list of combinations of i and j
# For diagonals, use diag() on slices of wordsearch: remove rows / cols and take diag()
search_line <- function(wordsearch, i, j, direction) {
  # Supply i and j as vectors for horizontal, vertical, and diagonal, components of wordsearch
  map2_chr(i, j, \(row, col) wordsearch[row, col]) |>
    collapse() |>
    search_string()
}

get_downward_diagonals <- function(matrix) {
  nrow <- dim(matrix)[[1]]
  ncol <- dim(matrix)[[2]]
  c(
    map(seq(2, nrow - 1), \(i) diag(matrix[seq(i, nrow),])),
    list(diag(matrix)),
    map(seq(2, ncol - 1), \(j) diag(matrix[, seq(j, ncol)]))
  ) |>
    map_chr(collapse)
}

flip_matrix <- function(matrix) {
  matrix[seq(NROW(matrix), 1),]
}

get_upward_diagonals <- function(matrix) {
  matrix |> flip_matrix() |> get_downward_diagonals()
}

get_horizontals <- function(wordsearch) {
  wordsearch |>
    NROW() |>
    seq() |>
    map(\(i) wordsearch[i, ]) |>
    map_chr(collapse)
}

get_verticals <- function(wordsearch) {
  wordsearch |>
    NCOL() |>
    seq() |>
    map(\(j) wordsearch[, j]) |>
    map_chr(collapse)
}

c(
  get_downward_diagonals(wordsearch),
  get_upward_diagonals(wordsearch),
  get_horizontals(wordsearch),
  get_verticals(wordsearch)
) |>
  search_string() |>
  sum()
