# AoC 2025 Day 02
# > https://adventofcode.com/2025/day/2

# Loop over subsets 1:(end/2)
# Check if in
# Expand range a-b to a:b
# Map lookup over

function parse_number(str::String)::Int64
    parse(Int64, str)
end

function expand_range(code::String)
    range(parse_number.(String.(split(code, '-')))...)
end

function is_duplicate(number::Int64)
    
    number_str = string(number)
    len = length(number_str)
    max_subset = round(Int64, len / 2, RoundNearestTiesAway) # Round to nearest whole

    number_str[1:max_subset] == number_str[(max_subset + 1):end]

end

function find_duplicates(number_range)
    filter(is_duplicate, number_range)
end

function is_multi_duplicate(number::Int64, n::Int64 = 2)
    
    number_str = string(number)
    len = length(number_str)
    search_up_to = round(Int64, len / n, RoundNearestTiesAway) # Round to nearest whole

    if number_str == number_str[1:search_up_to] ^ n
        true
    elseif n >= len
        false
    else
        is_multi_duplicate(number, n + 1)
    end

end

function find_multi_duplicates(number_range)
    filter(is_multi_duplicate, number_range)
end

input = readline("2025/Inputs/2025 Day 02.txt")

product_ranges = String.(split(input, ','))

# Part 1
# 24747430309
product_ranges .|> expand_range .|> find_duplicates |> filter(!isempty) .|> sum |> sum

# Part 2
# 30962646823
product_ranges .|> expand_range .|> find_multi_duplicates |> filter(!isempty) .|> sum |> sum
