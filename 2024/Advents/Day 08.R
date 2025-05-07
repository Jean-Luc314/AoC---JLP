library(tidyverse)

INPUT_PATH <- "2024/Inputs/Day 08.txt"
INPUT_PATH <- "2024/Inputs/Day 08 Example.txt"

# Plan:
# 1. Bring inputs into a tibble
#   i. Antenna field
#   ii. loc = c(row, column) field
# 2. Grouped by antenna, find all combinations of loc
# 3. Derive antinodes as list field
# 4. Unlist antinodes, doubling size of tibble
# 5. Filter by valid coordinates
# 6. Take unique values
# 7. Count antinodes

input <- read_lines(INPUT_PATH)

max_row <- length(input)
max_col <- nchar(input[1])

get_row <- function(id, max_row) {
  (id %/% max_row) + 1
}

get_col <- function(id, max_row) {
  ((id - 1) %% max_row) + 1
}

parse_input <- function(input) {

  input_single <- paste(input, collapse = "")

  tibble(
    antenna = input_single |>
      str_split("") |>
      first()
  ) |>
    mutate(id = row_number(),
           loc = map(id, \(id) c(get_row(id, max_row), get_col(id, max_row))),
           row = get_row(id, max_row),
           col = get_col(id, max_row)) |>
    filter(antenna != ".")

}

get_id <- function(row, col, max_row) {
  row * max_row + col
}

parsed_input <- input |> parse_input()

results <- crossing(
  parsed_input |> rename_with(\(field) paste(field, "1", sep = "_"), .cols = everything()),
  parsed_input |> rename_with(\(field) paste(field, "2", sep = "_"), .cols = everything())
) |>
  filter(id_1 != id_2, antenna_1 == antenna_2) |>
  mutate(antinode = map2(loc_1,
                         loc_2,
                         \(x, y) {

                           dt <- x - y

                           if (all(x + dt == y)) {
                             list(x - dt, x + 2 * dt)
                           } else {
                             list(x - 2 * dt, x + dt)
                           }
                         })) |>
  unnest(antinode) |>
  filter(map_lgl(antinode, \(coords) coords[1] |> between(1, max_row)), map_lgl(antinode, \(coords) coords[2] |> between(1, max_col)))
  #filter(!map_lgl(antinode, \(coords) coords[1] |> between(1, max_row)) | !map_lgl(antinode, \(coords) coords[2] |> between(1, max_col)))

results |>
  distinct(antinode) |>
  nrow() # 355

results |>
  View()

# Graphic looks wrong
# TODO: include in final output as a nice to have. Save and upload image.
results |>
  #filter(antenna_1 == "2") |>
  mutate(x_antinode = map_dbl(antinode, \(x) x[1]),
         y_antinode = map_dbl(antinode, \(y) y[2]),
         x_antenna = map_dbl(loc_1, \(x) x[1]),
         y_antenna = map_dbl(loc_1, \(y) y[2])) |>
  ggplot() +
  geom_point(aes(x_antinode, y_antinode), colour = "red") +
  geom_point(aes(x_antenna, y_antenna), colour = "blue") +
  facet_wrap(~ antenna_1) +
  # geom_point(aes(x_antinode, y_antinode, shape = antenna_1), colour = "red") +
  # geom_point(aes(x_antenna, y_antenna, shape = antenna_1), colour = "blue") +
  scale_x_reverse() +
  coord_flip()


