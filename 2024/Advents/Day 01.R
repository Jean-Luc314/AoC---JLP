library(tidyverse)
library(glue)

read_input <- function(day) readLines(glue("2024/Inputs/Day {day}.txt"))

process_data <- function(raw_list) {
  raw_list |>
    as_tibble() |>
    separate(value, c("id_1", "id_2")) |>
    mutate(across(everything(), as.numeric))
}

get_distance <- function(x, y) abs(x - y)

count_scores <- function(id_1, id_2) sum(id_1 == id_2)

day <- "01"

# Part 1 ------------------------------------------------------------------

day |>
  read_input() |>
  process_data() |>
  mutate(across(everything(), sort)) |>
  reduce(get_distance) |>
  sum() # 2742123

# Part 2 ------------------------------------------------------------------

day |>
  read_input() |>
  process_data() |>
  mutate(count = map_dbl(id_1, \(id_1) count_scores(id_1, id_2)),
         similarity_score = id_1 * count) |>
  pull(similarity_score) |>
  sum() # 21328497
