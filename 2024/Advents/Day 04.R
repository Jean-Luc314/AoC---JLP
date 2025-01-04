library(tidyverse)
source("helpers/helpers.R")

# Helpers -----------------------------------------------------------------

input_to_matrix <- function(input) {
  input |> str_split("") |> (\(chr) do.call(rbind, chr))()
}

collapse <- function(chr) paste(chr, collapse = "")

str_reverse <- function(str) {
  str |>
    str_split_1("") |>
    rev() |>
    collapse()
}

search_string <- function(str, word = "XMAS") str_count(str, word) + str_count(str, str_reverse(word))

# Part 1 ------------------------------------------------------------------

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

part_1 <- function(input) {

  wordsearch <- input_to_matrix(input)

  c(
    get_downward_diagonals(wordsearch),
    get_upward_diagonals(wordsearch),
    get_horizontals(wordsearch),
    get_verticals(wordsearch)
  ) |>
    search_string() |>
    sum()

}

input <- input_read_lines("2024", "04")

part_1(input) # 2618

# Part 2 ------------------------------------------------------------------

is_mas <- function(matrix, mas = "MAS") matrix |> diag() |> collapse() |> search_string(mas)

is_xmas <- function(matrix, mas = "MAS") is_mas(matrix, mas) & is_mas(flip_matrix(matrix), mas)

part_2 <- function(input) {

  wordsearch <- input_to_matrix(input)

  get_sub_matrix <- function(row, col, size = 3) wordsearch[row + seq(size) - 1, col + seq(size) - 1]

  crossing(row = seq(NROW(wordsearch) - 2), col = seq(NCOL(wordsearch) - 2)) |>
    mutate(subset = map2(row, col, get_sub_matrix),
           xmas = map_lgl(subset, is_xmas)) |>
    pull(xmas) |>
    sum()

}

part_2(input) # 2011
