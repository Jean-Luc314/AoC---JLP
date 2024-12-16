library(tidyverse)
source("helpers/helpers.R")

# Helpers -----------------------------------------------------------------

extract_instruction <- function(pattern) function(code) {
  code |> str_extract(pattern) |> as.numeric()
}

input <- input_read_lines("2024", "03")

# Part 1 ------------------------------------------------------------------

part_1 <- function(input) {

  tibble(
    program = input
  ) |>
    mutate(
      instructions = map(program,      partial(str_extract_all, pattern = "mul\\(\\d{1,3},\\d{1,3}\\)")),
      x            = map(instructions, partial(map, ... = , extract_instruction("\\d{1,3}"))),
      y            = map(instructions, partial(map, ... = , extract_instruction("(?<=,)\\d{1,3}"))),
      memory       = map2_dbl(x, y,    compose(sum, first, partial(map2, ... = , `*`)))) |>
    pull(memory) |>
    sum()

}

part_1(input) # 157621318

# Part 2 ------------------------------------------------------------------

as_switch <- function(toggle) toggle == "do()"

part_2 <- function(input) {

  instruction <- paste(input, collapse = "")

  split_instructions <- instruction |> str_split_1("do\\(\\)|don't\\(\\)")

  switch <- TRUE |> c(instruction |> str_extract_all("do\\(\\)|don't\\(\\)") |> first() |> map_lgl(as_switch))

  sum(map_dbl(split_instructions, part_1) * switch)

}

part_2(input) # 79845780
