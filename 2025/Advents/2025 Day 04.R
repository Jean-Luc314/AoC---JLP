
library(tidyverse)

file_path <- "2025/Inputs/2025 Day 04.txt"
#file_path <- "2025/Inputs/2025 Day 04 - Example.txt"

parse_input <- function(file_path) {

    file_path |>
        read_lines() |>
        map(partial(str_split_1, pattern = "")) |>
        partial(do.call, rbind)()

}

fill_safe_indices <- function(indices, bound) if_else(indices |> between(1, bound), indices, NA)

search_results <- function(input) {
    
    n_rows <- nrow(input)
    n_cols <- ncol(input)
    
    index_search <- list(
        up = fill_safe_indices(seq(0, n_rows-1), n_rows),
        down = fill_safe_indices(seq(2, n_rows+1), n_rows),
        left = fill_safe_indices(seq(0, n_cols-1), n_cols),
        right = fill_safe_indices(seq(2, n_cols+1), n_cols)
    )
    
    list(
        
        up = replace_na(input[index_search$up, ] == "@", FALSE),
        down = replace_na(input[index_search$down, ] == "@", FALSE),
        
        left = replace_na(input[, index_search$left] == "@", FALSE),
        right = replace_na(input[, index_search$right] == "@", FALSE),
        
        up_left = replace_na(input[index_search$up, index_search$left] == "@", FALSE),
        up_right = replace_na(input[index_search$up, index_search$right] == "@", FALSE),
        
        down_left = replace_na(input[index_search$down, index_search$left] == "@", FALSE),
        down_right = replace_na(input[index_search$down, index_search$right] == "@", FALSE)
    
    )
}

fill_matrix_na <- function(mat, fill = FALSE) {
    mat[is.na(mat)] <- fill
    mat
}

identify_removable_papers <- function(input) {
  reduce(map(search_results(input), fill_matrix_na), `+`) < 4
}

remove_papers <- function(input) {
  
  input[identify_removable_papers(input)] <- "."

  input
  
}

remove_all_papers <- function(input) {
  
  forklift_rolls <- remove_papers(input)
  
  if (all(input == forklift_rolls)) {
    input
  } else{
    remove_all_papers(forklift_rolls)
  }
  
}

# Part 1

input <- file_path |> parse_input()

sum((input == "@") * identify_removable_papers(input)) # 1320

# Part 2
# Turn this process into a function, using input[lgl] <- "." on the above reduce() condition
# Count the number removed
# Continue until all(input == output)

sum((input == "@") - (remove_all_papers(input) == "@")) # 8354

