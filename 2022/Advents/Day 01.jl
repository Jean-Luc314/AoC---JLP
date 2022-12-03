# Functions
struct elf
    items :: Vector{Int}
end
struct inventory
    list :: Vector{elf}
end

function read_inventory(string::String)::inventory
    function split_by_elf(inventory::String)::Vector{String}
        split(inventory, "\r\n\r\n") .|> String
    end
    function split_by_food(elves::Vector{String})::Vector{Vector{Int}}
        elves .|> x -> parse.(Int, split(x, "\r\n") .|> String)
    end
    read(string, String) |> split_by_elf |> split_by_food .|> elf |> inventory
end
function count_calories(e::elf)::Int
    e.items |> sum
end
function count_calories(i::inventory)::Vector{Int}
    i.list .|> count_calories
end

invent = read_inventory("2022/Inputs/Day 01.txt")
# Part 1
invent |> count_calories |> maximum
# Part 2
invent |> count_calories |> x -> sort(x, rev = true) |> x -> x[1:3] |> sum