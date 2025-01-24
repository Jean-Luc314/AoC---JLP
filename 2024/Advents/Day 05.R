library(tidyverse)
source("helpers/helpers.R")

input <- input_read_lines("2024", "05")

extract <- function(input, pattern) input[str_detect(input, pattern)]

parse_update <- function(update)  update |> str_split(",", simplify = TRUE) |> as.numeric()

is_page_in_order <- function(page, ordering_rules) function(next_page) {
  valid_next_pages <- ordering_rules |> filter(before == {{page}}) |> pull(after)
  next_page %in% valid_next_pages
}

is_correct_order <- function(ordering_rules) function(updates) {

  check_page <- function(index) {

    page <- updates[[index]]

    updates[seq(index + 1, length(updates))] |>
      map_lgl(is_page_in_order(page, ordering_rules)) |>
      all()

  }

  updates |>
    seq_along() |>
    head(-1) |>
    map_lgl(check_page) |>
    all()
}

is_incorrect_order <- function(ordering_rules) compose(`!`, is_correct_order(ordering_rules))

get_middle_index <- function(vec) vec[[floor(length(vec) / 2) + 1]]

get_ordering_rules <- function(input) {

  tibble(rules = extract(input, "\\|")) |>
    separate_wider_delim(rules, "|", names = c("before", "after")) |>
    mutate(across(everything(), as.numeric))

}

part_1 <- function(input) {

  ordering_rules <- get_ordering_rules(input)

  input |>
    extract(",") |>
    map(parse_update) |>
    keep(is_correct_order(ordering_rules)) |>
    map_dbl(get_middle_index) |>
    sum()

}

part_1(input) # 4569

swap_places <- function(ordering_rules, pages, i) {

  remaining_pages <- pages[seq(i + 1, length(pages))]

  swap_indices <- ordering_rules |>
    filter(before %in% remaining_pages, after == pages[[i]]) |>
    pull(before) |>
    match(pages)

  pages[c(i, swap_indices)] <- pages[c(swap_indices, i)]

  pages

}

reorder_page <- function(ordering_rules, pages, i = 1) {

  order_is_correct <- pages[seq(i + 1, length(pages))] |>
    map_lgl(is_page_in_order(pages[[i]], ordering_rules)) |>
    all()

  if (i == length(pages)) {
    pages
  } else if (order_is_correct) {
    reorder_page(ordering_rules, pages, i + 1)
  } else {
    reorder_page(ordering_rules, swap_places(ordering_rules, pages, i), i)
  }

}

part_2 <- function(input) {

  ordering_rules <- get_ordering_rules(input)

  input |>
    extract(",") |>
    map(parse_update) |>
    keep(is_incorrect_order(ordering_rules)) |>
    map(\(pages) reorder_page(ordering_rules, pages)) |>
    map_dbl(get_middle_index) |>
    sum() # 6456

}

