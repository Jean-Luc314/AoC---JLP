
function get_left_node(path::String)
    String(match(r"(?<=\().{3}", path).match)
end

function get_right_node(path::String)
    String(match(r".{3}(?=\))", path).match)
end

function get_current_node(path::String)
    String(match(r".{3}(?= \=)", path).match)
end

function build_left_turn_mappings(path::Vector{String})
    Dict(path .|> get_current_node .=> path .|> get_left_node)
end

function build_right_turn_mappings(path::Vector{String})
    Dict(path .|> get_current_node .=> path .|> get_right_node)
end

function take_step(position::String, mapping::Dict{String, String})
    mapping[position]
end

function take_step(position::String, direction::Char, left_turns::Dict{String, String}, right_turns::Dict{String, String})
    take_step(position, Dict('L' => left_turns, 'R' => right_turns)[direction])
end

# Loop through input paths until start_position == end_position
function part_one(start_position, end_position, inputs)
    
    # Initialise
    position = start_position
    i = 1
    counter = 0
    
    directions = inputs[1]
    recurse_at = length(directions)
    paths = inputs[3:end]
    
    left_turns = build_left_turn_mappings(paths)
    right_turns = build_right_turn_mappings(paths)

    while position != end_position
        direction = directions[i]
        position = take_step(position, direction, left_turns, right_turns)
        counter += 1
        i %= recurse_at
        i += 1
    end
    counter
end


inputs = readlines("2023/Inputs/Day 08.txt")
inputs = readlines("2023/Inputs/Day 08 Example.txt")
inputs = readlines("2023/Inputs/Day 08 Example 2.txt")
inputs = readlines("2023/Inputs/Day 08 Example 3.txt")

start_position = "AAA"
end_position = "ZZZ"

result = part_one(start_position, end_position, inputs) # 17141

# COMBAK: think about space of all inputs. Think about working backwards. Count first repeat? Think of nodes.

# Get all paths ending with 'A'
function is_ends_with(letter)
    function (path)
        path |> collect |> last == (letter)
    end
end

# Loop through input paths ending with 'A' until each step end with 'Z'
function part_two(inputs, initial_ends_with = 'A', terminal_ends_with = 'Z')
    
    # Initialise
    i = 1
    counter = 0
    
    directions = inputs[1]
    recurse_at = length(directions)
    paths = inputs[3:end]
    left_turns = build_left_turn_mappings(paths)
    right_turns = build_right_turn_mappings(paths)
    
    start_paths = paths[paths .|> get_current_node .|> is_ends_with(initial_ends_with)]
    positions = start_paths .|> get_current_node
    
    while !all(positions .|> is_ends_with(terminal_ends_with))
        direction = directions[i]
        positions = positions .|> (p -> take_step(p, direction, left_turns, right_turns))
        counter += 1
        i %= recurse_at
        i += 1
    end
    counter
end

result = part_two(inputs) # 


