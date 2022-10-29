# Functions
function to_direction(instructions::String)::Vector{Int}
    key = Dict("(" => 1, ")" => -1)
    lookup_key(x) = key[string(x)]
    instructions |> collect .|> lookup_key
end
function at_basement(directions::Vector{Int})::Int
    position = 0
    floor = 0
    while floor >= 0
        position += 1
        floor += popfirst!(directions)
    end
    position
end
instructions = read("2015/Input/Day 01.txt", String)
# Part 1
## Count the "("
instructions |> to_direction |> sum

# Part 2
instructions |> to_direction |> at_basement
