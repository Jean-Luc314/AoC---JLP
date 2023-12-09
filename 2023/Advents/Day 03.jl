
# Identify when next to a number / symbol. Anything not a "."
# Do with shifting?


engine_v = engine .|> collect
engine_v[1]

reshape(engine_v, (10, 10))

engine_matrix = reshape(reduce(vcat, engine_v), 10, 10)

.!is_period.(engine_matrix)

is_period(char::Char)                 = char == '.'
is_period(char::Vector{Char})         = is_period.(char)
is_period(char::Vector{Vector{Char}}) = is_period.(char)

is_period(engine_v[2:end])
is_period(engine_v[1:end - 1])

# Generate numbers by reducing left to right, line by line. Any "." is a separation. Collect into an array of ints.
# Once you have a number, can you identify whether it is surrounded by symbols? I.e., identify its location, then check neighbourhood.

parse_int(string::String) = parse(Int64, string)

function collect_parts(engine::String, storage::Vector{Int64} = Int64[])
    # Check if there are any remaining parts in the engine
    if occursin(r"[0-9]", engine)
        # Identify the first part, looking left to right
        # Parse the part into Int64
        part = parse_int(String(match(r"[0-9]+(?![0-9])", engine * ".").match))
        # Add the part to storage
        append!(storage, part)
        # Remove the identified part from the engine
        engine = replace(engine, part |> string |> Regex => "", count = 1)
        # Recurse
        collect_parts(engine, storage)
    else
        # Return the storage of engine parts
        storage
    end
end

linear_engine = prod(engine)

parts = engine |> prod |> collect_parts
part = parts[1]

engine_parts = collect_parts(linear_engine)

abstract type Direction end
struct Left      <: Direction end
struct Right     <: Direction end
struct Up        <: Direction end
struct Down      <: Direction end
struct Leftup    <: Direction end
struct Rightup   <: Direction end
struct Leftdown  <: Direction end
struct Rightdown <: Direction end

function boundary(engine::Vector{String}, direction::Type{T}) where T <: Direction
    map_direction = Dict(Left => 1, Right => length(engine[1]), Up => 1, Down => length(engine))
    map_direction[direction]
end

function look(engine::Vector{String}, lr::Integer, ud::Integer, direction::Type{Left})
    lr == boundary(engine, direction) ? '.' : engine[ud][lr - 1]
end

function look(engine::Vector{String}, lr::Integer, ud::Integer, direction::Type{Right})
    lr == boundary(engine, direction) ? '.' : engine[ud][lr + 1]
end

function look(engine::Vector{String}, lr::Integer, ud::Integer, direction::Type{Up})
    ud == boundary(engine, direction) ? '.' : engine[ud - 1][lr]
end

function look(engine::Vector{String}, lr::Integer, ud::Integer, direction::Type{Down})
    ud == boundary(engine, direction) ? '.' : engine[ud + 1][lr]
end

function look(engine::Vector{String}, lr::Integer, ud::Integer, direction::Type{Leftup})
    lr == boundary(engine, Left) || ud == boundary(engine, Up) ? '.' : engine[ud - 1][lr - 1]
end

function look(engine::Vector{String}, lr::Integer, ud::Integer, direction::Type{Rightup})
    lr == boundary(engine, Right) || ud == boundary(engine, Up) ? '.' : engine[ud - 1][lr + 1]
end

function look(engine::Vector{String}, lr::Integer, ud::Integer, direction::Type{Leftdown})
    lr == boundary(engine, Left) || ud == boundary(engine, Down) ? '.' : engine[ud + 1][lr - 1]
end

function look(engine::Vector{String}, lr::Integer, ud::Integer, direction::Type{Rightdown})
    lr == boundary(engine, Right) || ud == boundary(engine, Down) ? '.' : engine[ud + 1][lr + 1]
end

function look(engine::Vector{String}, part_location::Integer, direction::Type{T}) where T <: Direction
    linear_engine = prod(engine)
    nrow = length(engine[1])
    min_len = 0
    max_len = length(linear_engine)
    lr = Dict(
        Left      => -1,
        Right     =>  1,
        Up        =>  0,
        Down      =>  0,
        Leftup    => -1,
        Rightup   =>  1,
        Leftdown  => -1,
        Rightdown =>  1
        )
    ud = Dict(
        Left      =>  0,
        Right     =>  0,
        Up        =>  1,
        Down      => -1,
        Leftup    =>  1,
        Rightup   =>  1,
        Leftdown  => -1,
        Rightdown => -1
        )
    linear_engine[]
end

function remove_digits(string::String)
    filter(!isdigit, string)
end

function remove_periods(string::String)
    filter(!is_period, string)
end

# You've not allowed for multiple parts

function locate(part::Integer, engine::Vector{String})
    linear_engine = prod(engine)
    part_locations = findfirst(part |> string |> Regex, linear_engine)
    nrow = length(engine[1])
    lr = mod.(part_locations .- 1, nrow) .+ 1
    ud = div.(part_locations, nrow) .+ 1
    Dict("lr" => lr, "ud" => ud)
end

function locate(parts::Vector{T}, engine::Vector{String}) where T <: Integer
    map(p -> locate(p, engine), parts)
end

function locate(engine::Vector{String})
    locate(engine |> prod |> collect_parts, engine)
end

function filter_symbols(engine::Vector{String}, locations::Dict{String, Vector{T}}, i) where T <: Integer
    println(i)
    lr = locations["lr"]
    ud = locations["ud"]
    neighbours = reduce(
        (list, direction) -> list * prod([string(look(engine, x, y, direction)) for (x, y) in zip(lr, ud)]),
        [Up, Down, Left, Right, Leftup, Leftdown, Rightup, Rightdown],
        init = ""
        )
    neighbours |> remove_digits |> remove_periods
end

function filter_symbols(engine::Vector{String})
    map((locations, i) -> filter_symbols(engine, locations, i), locate(engine), 1:length(locate(engine)))
end

function sum_part_numbers(engine::Vector{String})
    parts = engine |> prod |> collect_parts
    adjacent_symbols = filter_symbols(engine)
    sum(parts .* (adjacent_symbols .!= ""))
end

engine = readlines("2023/Inputs/Day 03.txt")

sum_part_numbers(engine) # 516269

i = 311
locations = locate(engine)
locations = locations[i]

# All are length 140
all(length.(engine) .== 140)

engine = engine[125:127]
parts = engine |> prod |> collect_parts
adjacent_symbols = filter_symbols(engine)

filter_symbols(engine, locate(84, engine), 1)

## Start again
# This time, work within a String environment, calculate boundaries using `mod() == 0` or `1`.

struct Engine
    components::String
    nrow::Integer
    ncol::Integer
end

function Engine(engine::Vector{String})
    if all(length.(engine) .== length(engine[1]))
        Engine(prod(engine), length(engine), length(engine[1]))
    else
        error("engine must have square dimensions")
    end
end

engine = ["467..114..", "...*......", "..35..633.", "......#...", "617*......", ".....+.58.", "..592.....", "......755.", "...\$.*....", ".664.598.."]

engine = Engine(engine)

components = engine.components

storage = Dict{Vector{Integer}, Integer}()

parse_int(string::String) = parse(Int64, string)

function collect_parts(components::String, storage::Dict{Vector{T}, T}) where T <: Integer
    # Check if there are any remaining parts in the engine
    if occursin(r"[0-9]", components)
        search_part = r"[0-9]+"
        # Identify part's location
        part_indices = findfirst(search_part, components)
        # Parse the part into Int64
        part = parse_int(components[part_indices])
        # Add to collection
        storage[part_indices] = part
        # Remove part from components
        components = replace(components, search_part => "_" ^ length(part_indices), count = 1)
        # Recurse
        collect_parts(components, storage)
    else
        # Return the storage of engine parts
        storage
    end
end

function collect_parts(engine::Engine)
    collect_parts(engine.components, Dict{Vector{Integer}, Integer}())
end

function collect_parts(engine::String)
    [engine] |> Engine |> collect_parts
end

function collect_parts(engine::Vector{String})
    engine |> Engine |> collect_parts
end

abstract type Direction end
struct Left      <: Direction end
struct Right     <: Direction end
struct Up        <: Direction end
struct Down      <: Direction end
struct Leftup    <: Direction end
struct Rightup   <: Direction end
struct Leftdown  <: Direction end
struct Rightdown <: Direction end

function look(position::Integer, engine::Engine, direction::Type{T}) where T <: Direction
    blank = '.'
    components = engine.components
    maxrow = engine.nrow
    maxcol = engine.ncol
    x = mod(position - 1, maxrow) + 1
    y = div(position, maxrow) + 1
    map_direction = Dict(
        Left      => x == 1                     ? blank : components[position - 1],
        Right     => x == maxcol                ? blank : components[position + 1],
        Up        => y == 1                     ? blank : components[position - maxcol],
        Down      => y == maxrow                ? blank : components[position + maxcol],
        Leftup    => x == 1      || y == 1      ? blank : components[position - maxcol - 1],
        Rightup   => x == maxcol || y == 1      ? blank : components[position - maxcol + 1],
        Leftdown  => x == 1      || y == maxrow ? blank : components[position + maxcol - 1],
        Rightdown => x == maxcol || y == maxrow ? blank : components[position + maxcol + 1]
        )
        map_direction[direction]
end
    
look(23, engine, Rightup)

function clockwise()
    [Left, Leftup, Up, Rightup, Right, Rightdown, Down, Leftdown]
end

function look(position::Integer, engine::Engine)
    prod(map(direction -> look(position, engine, direction), clockwise()))
end
    
function look(position::Vector{T}, engine::Engine) where T <: Integer
    map(p -> look(p, engine), position)
end

look([23, 24], engine)

function remove_digits(string::String)
    filter(!isdigit, string)
end

is_period(char::Char) = char == '.'

function remove_periods(string::String)
    filter(!is_period, string)
end

position = [1, 2, 3]

function is_part(position::Vector{T}, engine::Engine) where T <: Integer
    neighbours = look(position, engine)
    neighbours .|> remove_digits .|> remove_periods .|> ==("") |> !all
end

function is_part(position::Dict{Vector{Integer}, Integer}, engine::Engine)
    map(key -> is_part(key, engine), position |> keys |> collect)
end

# Collect parts is broken
position = collect_parts(engine)

is_part(position, engine)

function sum_parts(engine::Engine)
    position = collect_parts(engine)
    valid_parts = is_part(position, engine)
    parts = position |> values |> collect
    sum(parts .* valid_parts)
end

engine = "2023/Inputs/Day 03.txt" |> readlines |> Engine

# Part 1
engine |> sum_parts # 520019

function collect_stars(components::String, storage::Vector{T}) where T <: Integer
    # Check if there are any remaining parts in the engine
    if occursin(r"\*", components)
        search_gear = r"\*"
        # Identify part's location
        gear_index = findfirst(search_gear, components)
        # Add to collection
        append!(storage, gear_index)
        # Remove part from components
        components = replace(components, search_gear => "_", count = 1)
        # Recurse
        collect_stars(components, storage)
    else
        # Return the storage of engine parts
        storage
    end
end

function is_gear(stars::Integer)
    neighbours = look(stars, engine)
    neighbours |> collect_parts |> length |> ==(2)
end

function collect_stars(engine::Engine)
    collect_stars(engine.components, Vector{Integer}())
end

function collect_gears(engine::Engine)
    stars = collect_stars(engine)
    filter(is_gear, stars)
end

function find_gear_index(position::Integer, engine::Engine, direction::Type{T}) where T <: Direction
    blank = '.'
    maxrow = engine.nrow
    maxcol = engine.ncol
    x = mod(position - 1, maxrow) + 1
    y = div(position, maxrow) + 1
    map_direction = Dict(
        Left      => x == 1                     ? blank : position - 1,
        Right     => x == maxcol                ? blank : position + 1,
        Up        => y == 1                     ? blank : position - maxcol,
        Down      => y == maxrow                ? blank : position + maxcol,
        Leftup    => x == 1      || y == 1      ? blank : position - maxcol - 1,
        Rightup   => x == maxcol || y == 1      ? blank : position - maxcol + 1,
        Leftdown  => x == 1      || y == maxrow ? blank : position + maxcol - 1,
        Rightdown => x == maxcol || y == maxrow ? blank : position + maxcol + 1
        )
        map_direction[direction]
end

function search_part(neighbours::String)
    indices = findfirst(r"[0-9].+[0-9]", neighbours)
    part_1_direction = clockwise()[indices[begin]]
    part_2_direction = clockwise()[indices[end]]
    [part_1_direction, part_2_direction]
end

function calculate_gear_ratio(gear::Integer, engine::Engine)
    neighbours = look(gear, engine)
    gear_index_1 = find_gear_index(gear, engine, search_part(neighbours)[1])
    gear_index_2 = find_gear_index(gear, engine, search_part(neighbours)[2])
    parts = engine |> collect_parts
    part_values = parts |> values |> collect
    is_gear_part_1 = parts |> keys |> collect .|> (x -> gear_index_1 ∈ x)
    is_gear_part_2 = parts |> keys |> collect .|> (x -> gear_index_2 ∈ x)
    sum(is_gear_part_1 .* part_values) * sum(is_gear_part_2 .* part_values)
end

function calculate_gear_ratio(engine::Engine)
    gears = collect_gears(engine)
    sum(map(g -> calculate_gear_ratio(g, engine), gears))
end

calculate_gear_ratio(engine) # 75519888

