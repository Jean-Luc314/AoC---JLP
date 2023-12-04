# Define Cubes
abstract type Cube end
struct Red   <: Cube end
struct Green <: Cube end
struct Blue  <: Cube end

parse_int(string::String) = parse(Int64, string)

function get_id(game::String)
    # Return ID
    # Match one or more digits that come before a ":"
    match(r"[0-9]+(?:)", game).match |> String |> parse_int
end

function remove_id(game::String)
    # Replace ID with ""
    # Match on "Game " followed by one or more digits, then a ":"
    replace(game, r"Game [0-9]+:" => "")
end

function split_set(game::String)
    # Identify sets that are seperated by ";"
    # Convert Vector{Substring{String}} => Vector{String}
    String.(split(game, ";"))
end

function get_sets(game::String)
    # Return vector of games
    game |> remove_id |> split_set
end

function get_cube(type::Type{T}) where T <: Cube
    # Return a text representation of a Cube
    map_cube = Dict(Red => "red", Green => "green", Blue => "blue")
    map_cube[type]
end

function fill_missing(game::String, type::Type{T}) where T <: Cube
    # Where a Cube is not represented in a game, append ", 0 {type}" to the game
    cube = get_cube(type)
    occursin(Regex(cube), game) ? game : game * ", 0 " * cube
end

function fill_missing(game::String)
    # Loop through the Cube types and `fill_missing(game)`
    reduce(fill_missing, [Red, Green, Blue], init = game)
end

function get(game::String, type::Type{T}) where T <: Cube
    # Return the Cube value
    cube       = get_cube(type)
    # Match on digits that follow the cube text representation
    match_cube = "[0-9]+(?= " * cube * ")"
    cube_count = match(Regex(match_cube), game).match
    cube_count |> String |> parse_int
end

function is_possible(game::String)
    # Determine whether a game is possible, subject to constraints on the bag's Cube counts
    # Setup constraints
    constraints = Dict(Red => 12, Green => 13, Blue => 14)
    # Set up the game
    # Remove ID, split into sets, and fill missing Cube values for each set
    sets = game |> remove_id |> get_sets .|> fill_missing
    # Get cube counts
    reds   = get.(sets, Red)
    greens = get.(sets, Green)
    blues  = get.(sets, Blue)
    # Check constraints
    reds_pass   = reds   .<= constraints[Red]
    greens_pass = greens .<= constraints[Green]
    blues_pass  = blues  .<= constraints[Blue]
    # Check every constraint passes for each set
    sets_pass = reds_pass .& greens_pass .& blues_pass
    # Check all sets pass
    all(sets_pass)
end

function sum_valid(games::Vector{String})
    id = get_id.(games)
    valid_games = is_possible.(games)
    sum(id .* valid_games)
end

function get_min_set(game::String)
    # Calculate the minimum set of Cubes necessary for a game
    # Set up the game
    # Remove ID, split into sets, and fill missing Cube values for each set
    sets = game |> remove_id |> get_sets .|> fill_missing
    # Get cube counts
    reds   = get.(sets, Red)
    greens = get.(sets, Green)
    blues  = get.(sets, Blue)
    # Get minimum number of cubes necessary
    max_reds   = maximum(reds)
    max_greens = maximum(greens)
    max_blues  = maximum(blues)
    # Return the Minimum Set
    Dict(Red => max_reds, Green => max_greens, Blue => max_blues)
end

function get_power(set::Dict{DataType, Int64})
    set |> values |> prod
end

games = readlines("2023/Inputs/Day 02.txt")

# Part 1
sum_valid(games) # 2085
# Part 2
games .|> get_min_set .|> get_power |> sum # 79315

