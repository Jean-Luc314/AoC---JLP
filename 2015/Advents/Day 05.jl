# Functions
## Part 1
function test_vowels(string::String)::Bool
    vowels = ['a', 'e', 'i', 'o', 'u']
    count_vowels(string) = (string |> collect .|> char -> in(char, vowels)) |> sum
    test_3_or_more(n_vowels) = n_vowels >= 3
    string |> count_vowels |> test_3_or_more
end
function test_adjacent(string::String)::Bool
    count_adjacent(vec) = (vec[begin:end-1] .== vec[begin+1:end]) |> sum
    test_positive(vec) = vec > 0
    string |> collect |> count_adjacent |> test_positive
end
function test_exclusions(string::String)::Bool
    exclude = ["ab", "cd", "pq", "xy"]
    matches = exclude .|> excl -> occursin(excl, string)
    matches |> !any
end
function test_nice(string::String, tests::Vector{Function} = [test_vowels, test_adjacent, test_exclusions])::Bool
    results = tests .|> f -> f(string)
    reduce(.&, results) |> Bool
end
## Part 2
function test_pair(string::String)::Bool
    # Test any repeated pair of characters
    occursin(r"(..).*\1", string)
end
function test_sandwich(string::String)::Bool
    # Test any letter repeated with one letter between
    occursin(r"(.).\1", string)
end
# Read
strings = read("2015/Input/Day 05.txt", String) |> x -> split(x, "\r\n") .|> String
# Part 1
strings .|> test_nice |> sum
# Part 2
test_nice_improved(string) = test_nice(string, [test_pair, test_sandwich])
strings .|> test_nice_improved |> sum