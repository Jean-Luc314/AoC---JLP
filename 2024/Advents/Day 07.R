# Load libraries
library(tidyverse) # Data manipulation
library(glue) # String interpolation

# Location of the input files
LOC <- "2024/Inputs"

# Read input data from text files
# Example input for testing
#inputs <- readLines(glue("{LOC}/Day 07 Example.txt"))
# Actual input
inputs <- readLines(glue("{LOC}/Day 07.txt"))


# Planning ----------------------------------------------------------------

# Goal: identify which equations are soluble (that can tally against the total)
# Plan:
# 1. Parse each input line into a list containing the target total and the
#    numbers to operate on
# 2. Generate all combinations of operator: +, *, and || (Part 2 only)
# 3. Recursively evaluate each equation using the operators
# 4. Compare the result against the target total
# 5. Filter the input lines based on whether the target matched the total
# 6. Sum the totals from the soluble equations

# Function Definitions ----------------------------------------------------

#' Parse Input String
#'
#' Parses a string representing an equation into a list containing the target total
#' and the numbers to operate on.
#'
#' @param input A string representing an equation (e.g., "10: 1 2 3").
#' @return A list with two elements: 'total' (numeric) and 'entries' (numeric vector).
parse_input <- function(input) {

  list(
    total = input |> str_extract("[0-9]+") |> as.numeric(),
    entries = input |> str_remove("[0-9]+: ") |> str_split_1(" ") |> as.numeric()
  )

}

#' Custom Concatenation Operator
#'
#' Defines a custom operator `%||%` for concatenating two numbers.
#'
#' Scientific notation is set to `FALSE` to prevent errors from R converting
#' values to scientific notation within `paste0()`
#'
#' Wrapping `%...%` is not technically needed here, but poor it's practice to
#' overwrite the existing `||` function
#'
#' @param x First number.
#' @param y Second number.
#' @return The concatenated number.
`%||%` <- function(x, y) as.numeric(paste0(format(x, scientific = FALSE), format(y, scientific = FALSE)))

#' Evaluate Numbers with Operators
#'
#' Evaluates a vector of numbers using a vector of operators.
#'
#' @param numbers A numeric vector of numbers.
#' @param operations A character vector of operators (+, *, ||).
#' @return The result of the evaluation.
evaluate_numbers <- function(numbers, operations) {

  result <- numbers[[1]]

  for (i in seq_along(operations)) {

    if (operations[[i]] == "+") {

      result <- result + numbers[[i + 1]]

    } else if (operations[[i]] == "*") {

      result <- result * numbers[[i + 1]]

    } else if (operations[[i]] == "||") {

      result <- result %||% numbers[[i + 1]]

    } else {
      stop("Expecting either \"+\", \"*\", or \"||\"")
    }

  }

  result

}

#' Check Equation Part 1
#'
#' Checks if an equation is soluble using only '+' and '*' operators.
#'
#' @param input A list containing the target total and numbers (from parse_input).
#' @return TRUE if the equation is soluble, FALSE otherwise.
check_equation_part_1 <- function(input) {

  operators <- c("+", "*") # Operators to use

  combinations <- length(input$entries) - 1 # Number of operator combinations

  # Generate all combinations of operators
  op_combinations_df <- expand_grid(!!!rep(list(operators), combinations))
  op_combinations_list <- map(seq(nrow(op_combinations_df)), \(i) as.character(unname(as.list(op_combinations_df[i, ]))))

  # Check if any combination matches the target total
  any(input$total == map_dbl(op_combinations_list, \(op) evaluate_numbers(input$entries, op)))
}

# Part 1: Calculate the sum of soluble equation totals using '+' and '*'
part1_result <- inputs |>
  map(parse_input) |> # Parse each input line
  keep(check_equation_part_1) |> # Keep only soluble equations
  map_dbl(\(input) input$total) |> # Extract the target totals
  sum()
print(glue("Part 1 Result: {part1_result}")) # 538191549061

# Part 2 ------------------------------------------------------------------

#' Check Equation Part 2
#'
#' Checks if an equation is soluble using '+', '*', and '||' operators.
#'
#' @param input A list containing the target total and numbers (from parse_input).
#' @return TRUE if the equation is soluble, FALSE otherwise.
check_equation_part_2 <- function(input) {

  operators <- c("+", "*", "||") # Operators to use

  combinations <- length(input$entries) - 1 # Number of operator combinations

  # Generate all combinations of operators
  op_combinations_df <- expand_grid(!!!rep(list(operators), combinations))
  op_combinations_list <- map(seq(nrow(op_combinations_df)), \(i) as.character(unname(as.list(op_combinations_df[i, ]))))

  # Check if any combination matches the target total
  any(input$total == map_dbl(op_combinations_list, \(op) evaluate_numbers(input$entries, op)))
}

# Part 2: Calculate the sum of soluble equation totals using '+', '*', and '||'
part2_result <- inputs |>
  map(parse_input) |> # Parse each input line
  keep(check_equation_part_2) |> # Keep only soluble equations
  map_dbl(\(input) input$total) |> # Extract the target totals
  sum() # Calculate the sum

print(glue("Part 2 Result: {part2_result}")) # 34612812972206
