input_file = readlines("2025/Inputs/2025 Day 06.txt")

parse_int = x -> parse.(Int64, x)
split_whitespace = x -> String.(split(x, r"\s+"))
filter_blank = x -> filter(!=(""), x)
parse_input = filter_blank ∘ split_whitespace
remove_last = x -> x[1:end-1]
convert_to_operator = x -> getfield(Base, Symbol(x))
transpose = x -> [[row[i] for row in x] for i in 1:length(x[1])]

# Part 1
numbers = input_file .|> parse_input |> remove_last .|> parse_int |> transpose
operators = input_file .|> parse_input |> last .|> convert_to_operator

sum(map(reduce, operators, numbers)) # 6169101504608

# Part 2
split_empty = x -> String.(split(x, ""))
concat_string = x -> reduce(*, x)
remove_whitespace = x -> replace(x, r"\s+" => "")
function split_on(predicate, v)
    result = [String[]]
    for i in v
        if predicate(i)
            push!(result, String[])
        else
            push!(result[end], i)
        end
    end
    result
end
split_on_whitespace = x -> split_on(==(""), x)

numbers_cephalopod = input_file |> remove_last .|> split_empty |> transpose .|> concat_string .|> remove_whitespace |> split_on_whitespace .|> parse_int
sum(map(reduce, operators, numbers_cephalopod)) # 10442199710797
