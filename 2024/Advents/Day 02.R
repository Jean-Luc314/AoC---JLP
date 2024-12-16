library(tidyverse)
source("helpers/helpers.R")

read_report_levels <- function(report) {
  report |>
    str_split_1("\\s+") |>
    as.numeric()
}

# Part 1 ------------------------------------------------------------------

is_strict_monotonic <- function(x) all(diff(x) > 0) | all(diff(x) < 0)

is_smooth <- function(x) x |> diff() |> abs() |> between(1, 3) |> all()

is_safe <- function(x) is_strict_monotonic(x) & is_smooth(x)

reports <- input_read_lines("2024", "02")

reports |>
  map(read_report_levels) |>
  map_lgl(is_safe) |>
  sum() # 242

# Part 2 ------------------------------------------------------------------

forgive_bad_report <- function(report) {

  report_levels <- read_report_levels(report)

  c(
    list(report_levels),
    map(seq_along(report_levels), \(index) report_levels[-index])
  ) |>
    map_lgl(is_safe) |>
    any()

}

reports |>
  map_lgl(forgive_bad_report) |>
  sum() # 311

