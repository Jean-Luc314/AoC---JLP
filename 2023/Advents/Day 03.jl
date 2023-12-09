# Part 1 Functions
struct Engine
    # An object holding the engine, represented as a String
    components::String
    # Use dimensions to identify boundaries of the engine
    # And to look up, down, left, right, etc
    nrow::Integer
    ncol::Integer
end

function Engine(engine::Vector{String})
    # Construct an Engine from a Vector{String}
    # Check the input is square
    if all(length.(engine) .== length(engine[1]))
        Engine(prod(engine), length(engine), length(engine[1]))
    else
        error("engine must have square dimensions")
    end
end

# Convert String => Int64
parse_int(string::String) = parse(Int64, string)

function collect_parts(components::String, storage::Dict{Vector{T}, T}) where T <: Integer
    # Collect all the `parts`, numbers, in a String via recursion
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
    # Expand `collect_parts` to an Engine object
    collect_parts(engine.components, Dict{Vector{Integer}, Integer}())
end

function collect_parts(engine::String)
    # Expand `collect_parts` to an Engine object without defining `storage`
    [engine] |> Engine |> collect_parts
end

function collect_parts(engine::Vector{String})
    # Expand `collect_parts` to Vector{Engine}
    engine |> Engine |> collect_parts
end

# Define Direction classes
# Given a component of the Engine, Direction will identify which adjacent component to inspect
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
    # Given a `position` in the `engine`, extract the component from the relevent `direction`
    blank = '.' # Use `blank` for boundaries
    components = engine.components
    maxrow = engine.nrow
    maxcol = engine.ncol
    # Coordinates in square space identifies the boundaries of the `engine`
    # Horizontal coordinate in the square Engine. I.e., a column in Vector{String}
    x = mod(position - 1, maxrow) + 1
    # Vertical coordinate in the square Engine. I.e., a row in Vector{String}
    y = div(position, maxrow) + 1
    # For boundaries, LHS, RHS, Top, Bottom, return `blank`
    # Otherwise, return the adjacent component from `engine`
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
    
function clockwise()
    # Vector of clockwise Directions
    [Left, Leftup, Up, Rightup, Right, Rightdown, Down, Leftdown]
end

function look(position::Integer, engine::Engine)
    # Loop `clockwise()` and return the adjacent components as a string
    prod(map(direction -> look(position, engine, direction), clockwise()))
end
    
function look(position::Vector{T}, engine::Engine) where T <: Integer
    # Expand `look()` to operate on Vector{Integer}
    map(p -> look(p, engine), position)
end

function remove_digits(string::String)
    # Remove all [0-9] from a string
    filter(!isdigit, string)
end

# Identify '.' from a string
is_period(char::Char) = char == '.'

function remove_periods(string::String)
    # Remove all '.' from a string
    filter(!is_period, string)
end

function is_part(position::Vector{T}, engine::Engine) where T <: Integer
    # Identify all adjacent components using `look()`
    neighbours = look(position, engine)
    # Ignoring numbers and '.', any remaining symbols implies the `position` is a `part`
    neighbours .|> remove_digits .|> remove_periods .|> ==("") |> !all
end

function is_part(position::Dict{Vector{Integer}, Integer}, engine::Engine)
    # Expand `is_part()` to operate on a Dict mapping of `position` to `part`
    map(key -> is_part(key, engine), position |> keys |> collect)
end

function sum_parts(engine::Engine)
    # Collect all the `parts` of an `engine`
    position = collect_parts(engine)
    # Identify which `parts` have adjacent symbols
    valid_parts = is_part(position, engine)
    parts = position |> values |> collect
    # Return the total of the valid `parts`
    sum(parts .* valid_parts)
end

engine = "2023/Inputs/Day 03.txt" |> readlines |> Engine

# Part 1
engine |> sum_parts # 520019

# Part 2 Functions

function collect_stars(components::String, storage::Vector{T}) where T <: Integer
    # Similar to `collect_parts()`, collect all the "*" in a String via recursion
    # Return the indices of the gears within an `engine`
    # The "*" will identify when `parts` are a `gear`
    # Check if there are any remaining "*" in the engine
    if occursin(r"\*", components)
        search_gear = r"\*"
        # Identify "*" location
        gear_index = findfirst(search_gear, components)
        # Add to collection
        append!(storage, gear_index)
        # Remove "*" from components
        components = replace(components, search_gear => "_", count = 1)
        # Recurse
        collect_stars(components, storage)
    else
        # Return the storage of engine parts
        storage
    end
end

function is_gear(stars::Integer)
    # Given `gear`'s location, determine wether it is valid
    # A `gear` is valid if it is next to exactly 2 parts
    
    # Collect adjacent parts to the `stars`
    neighbours = look(stars, engine)
    # Use expanded `collect_parts()` to filter for parts
    # Check if there are exactly two `part` `neighbours`
    neighbours |> collect_parts |> length |> ==(2)
end

function collect_stars(engine::Engine)
    # Expand `collect_stars()` to operate on an Engine
    collect_stars(engine.components, Vector{Integer}())
end

function collect_gears(engine::Engine)
    # Collect all the indices of valid gears
    stars = collect_stars(engine) # Gear indices
    filter(is_gear, stars)        # Check `gear` constraints
end

function find_gear_index(position::Integer, engine::Engine, direction::Type{T}) where T <: Direction
    # Similar to `look()`, except the index of the neighbour is returned
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
    # Given a String of `neighbours`, identify the indices of the [0-9] digits
    # For example, neighbours = "0....6.." corresponds to the neighours of a `position`,
    # where `neighbours[1]` corresponds to `look(position, engine, clockwise()[1])`, etc
    # Use findfirst to extract extact the indices of `neighbours` that start and end with [0-9]
    # Using the indices, identify which Direction the part corresponded to
    indices = findfirst(r"[0-9].+[0-9]", neighbours)
    part_1_direction = clockwise()[indices[begin]]
    part_2_direction = clockwise()[indices[end]]
    [part_1_direction, part_2_direction]
end

function calculate_gear_ratio(gear::Integer, engine::Engine)
    # Given a `gear` index, indentify the, exactly, two neighbouring `parts`
    # Calculate the `gear_ratio` as sum( part_1 * part_2 )

    # Identify adjacent components of a `gear` index
    neighbours = look(gear, engine)
    # Identify which directions the `parts` are relative to the `gear`. E.g., Left, Rightdown, etc.
    part_1_direction, part_2_direction = search_part(neighbours)
    # Using the `part` direction, get the index location of the `part` within `engine.components`
    gear_index_1 = find_gear_index(gear, engine, part_1_direction)
    gear_index_2 = find_gear_index(gear, engine, part_2_direction)
    parts = engine |> collect_parts # Collection of `Vector[Indices] => part_value`
    part_values = parts |> values |> collect
    # Vector to identify which part corresponds to the `gear`. There will be a single 1, all other entries 0
    is_gear_part_1 = parts |> keys |> collect .|> (part_indices -> gear_index_1 ∈ part_indices)
    is_gear_part_2 = parts |> keys |> collect .|> (part_indices -> gear_index_2 ∈ part_indices)
    # Calculate `gear_ratio`
    sum(is_gear_part_1 .* part_values) * sum(is_gear_part_2 .* part_values)
end

function calculate_gear_ratio(engine::Engine)
    # Expand `calculate_gear_ratio` to operate on an Engine
    
    # Collect all valid gears
    gears = collect_gears(engine)
    # Calculate and sum the gear ratios
    sum(map(g -> calculate_gear_ratio(g, engine), gears))
end

# Part 2
calculate_gear_ratio(engine) # 75519888

