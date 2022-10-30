# Functions
function to_char(moves::String)::Vector{Char}
    split(moves, "") .|> only
end
function move!(location::Vector{Int}, direction::Char)
    map_move = Dict('^' => [0, 1], 'v' => [0, -1], '>' => [1, 0], '<' => [-1, 0])
    location .+= map_move[direction]
end
"""
    deliver(moves)

Track the locations and deliveries that Santa performs.

Valid move elements include: '^', 'v', '>', '<'.
"""
function deliver(moves::Vector{Char})::Dict{Vector{Int}, Int}
    moves = copy(moves)
    record = Dict([0, 0] => 1)
    location = [0, 0]
    while length(moves) > 0
        direction = popfirst!(moves)
        move!(location, direction)
        loc = copy(location)
        if location in keys(record)
            record[loc] += 1
        else
            record[loc] = 1
        end
    end
    record
end
"""
    robo_deliver(moves)

Help santa with a robotic duplicate.

Instructions alternate between Santa and Robotic Santa.
"""
function robo_deliver(moves::Vector{Char})::Dict{Vector{Int}, Int}
    santa = moves[begin:2:end] |> deliver
    robot = moves[begin + 1:2:end] |> deliver
    merge(+, santa, robot)
end
function count_destinations(record::Dict{Vector{Int}, Int})::Int
    record |> keys |> length
end
# Read
moves = read("2015/Input/Day 03.txt", String) |> to_char
# Part 1
moves |> deliver |> count_destinations
# Part 2
moves |> robo_deliver |> count_destinations