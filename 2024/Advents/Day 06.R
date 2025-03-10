library(tidyverse)
library(future)
library(future.apply)
library(progressr)
source("helpers/helpers.R")

input <- input_read_lines("2024", "06")
#input <- input_read_lines_example("2024", "06")

add_one <- function(x) x + 1

where_next <- function(guard, puzzle_map) {

  phantom_guard <- move(guard)

  substring(puzzle_map, phantom_guard$location, phantom_guard$location)

}

save_place <- function(guard) {
  guard$historic_loc <- c(guard$historic_loc, guard$location)
  guard$historic_dir <- c(guard$historic_dir, guard$direction)
  guard
}

move_up <- function(guard) {
  guard$location <- guard$location - guard$map_width
  guard
}

move_right <- function(guard) {
  guard$location <- guard$location + 1
  guard
}

move_down <- function(guard) {
  guard$location <- guard$location + guard$map_width
  guard
}

move_left <- function(guard) {
  guard$location <- guard$location - 1
  guard
}

move <- function(guard) {
  move_direction <- c("up" = move_up,
                      "right" = move_right,
                      "down" = move_down,
                      "left" = move_left)[[guard$direction]]

  guard |>
    move_direction() |>
    save_place()
}

turn <- function(guard) {
  guard$direction <- c(
    "up" = "right",
    "right" = "down",
    "down" = "left",
    "left" = "up"
  )[[guard$direction]]
  guard
}

step <- function(guard, puzzle_map) {

  if (where_next(guard, puzzle_map) == "#") {
    turn(guard)
  } else {
    move(guard)
  }

}

project_shift_work <- function(guard, puzzle_map, detect_loop = FALSE) {

  while (where_next(guard, puzzle_map) != "@") {

    guard <- step(guard, puzzle_map)

    is_looping <- any(duplicated(paste(guard$historic_loc, guard$historic_dir)))

    if (detect_loop & is_looping) {

      guard$is_loop <- TRUE

      return(guard)

    }

  }

  guard

}

# Part 1 ------------------------------------------------------------------

map_width <- input |>
  map_dbl(nchar) |>
  unique() |>
  add_one()

# Collapse to single string with "@" as the boundaries
border <- paste(rep("@", map_width), collapse = "")
puzzle_map <- paste(c(border, input, border), collapse = "@")

starting_place <- str_locate(puzzle_map, "\\^")[[1]]

guard <- list(
  location = starting_place,
  direction = "up",
  historic_loc = starting_place,
  historic_dir = "up",
  is_loop = FALSE,
  map_width = map_width
)

part_1 <- function(guard) {

  night_shift <- project_shift_work(guard, puzzle_map)

  night_shift$historic_loc |> unique() |> length()

}

part_1(guard) # 5212


# Part 2 ------------------------------------------------------------------

obstruct_map <- function(puzzle_map, loc, replacement = "#") {

  str_c(
    str_sub(puzzle_map, 1, loc - 1),
    replacement,
    str_sub(puzzle_map, loc + 1)
  )

}

guard
puzzle_map |> obstruct_map(14)

# Set up a parallel plan
# Use as many workers as there are cores
# Inefficient to go above this as the CPU will spend time switching processes
# instead of working
plan(multisession, workers = parallel::detectCores())

part_2 <- function(puzzle_map, guard) {

  # Detect a loop, use to subset
  # Run guard through subsets to check guard passes along the box to detect a repeat in historic_loc

  candidate_obstructions <- puzzle_map |>
    nchar() |>
    seq() |>
    keep(\(i) ! substring(puzzle_map, i, i) %in% c("@", "#", "^"))

  # Track progress through long loop
  with_progress({

    p <- progressor(steps = length(candidate_obstructions))

    tibble(candidate_obstructions) |>
      mutate(candidate_maps = map_chr(candidate_obstructions, \(loc) obstruct_map(puzzle_map, loc)),
             test_maps = future_lapply(candidate_maps,
                                       \(candidate_map) {
                                         p() # Increment progress
                                         project_shift_work(guard, candidate_map, detect_loop = TRUE)$is_loop
                                       }),
             test_maps = unlist(test_maps)) |>
      filter(test_maps) |>
      nrow()

  })

}
part_2_results <- part_2(puzzle_map, guard) # Estimate: 11 hours
part_2_results # 1767

# Switch back to sequential execution
plan(sequential)


