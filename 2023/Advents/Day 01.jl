# Functions
# Filter for only digits
filter_digit(value::String) = filter(isdigit, value)
filter_digit(value::Vector{String}) = filter_digit.(value)

# Convert value to Integer
parse_int(value::String) = parse(Int64, value)
parse_int(value::Vector{String}) = parse_int.(value)

# Convert to calibration code
## Concatenate first & last digits.
## Where only one character, duplicate
to_calibration(value::String) = length(value) == 1 ? value * value : value[begin] * value[end]
to_calibration(value::Vector{String}) = to_calibration.(value)

# Convert text numbers in a string to the Integer value
function parse_letters(value::String)
    ## Mapping duplicate first and last characters to allow values
    ## to be recorded twice.
    ## E.g., "eightwothree" converts to "e8t2ot3e" so that each of the "eight", "two", and "three" are represented
    map_letters = Dict(
        "one"   => "o1e",
        "two"   => "t2o",
        "three" => "t3e",
        "four"  => "f4r",
        "five"  => "f5e",
        "six"   => "s6x",
        "seven" => "s7n",
        "eight" => "e8t",
        "nine"  => "n9e" 
        )
    replace_word(value::String, word::String) = replace(value, word => map_letters[word])
    # Loop through `value` and replace every worded letter with its corresponding digit
    reduce(replace_word, keys(map_letters), init = value)
end
parse_letters(value::Vector{String}) = parse_letters.(value)

# Import Inputs
calibration_values = readlines("2023/Inputs/Day 01.txt")

# Part 1
calibration_values |>
    filter_digit |>
    to_calibration |>
    parse_int |>
    sum # 54338

# Part 2
calibration_values |>
    parse_letters |> # Allow for conversion of words to digits
    filter_digit |>
    to_calibration |>
    parse_int |>
    sum # 53389
