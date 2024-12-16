
input_read_lines <- function(year, day) readr::read_lines(glue::glue("{year}/Inputs/Day {day}.txt"))

input_read_lines_example <- function(year, day) readr::read_lines(glue::glue("{year}/Inputs/Day {day} Example.txt"))
