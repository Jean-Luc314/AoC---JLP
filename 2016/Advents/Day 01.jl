# Day 01
## Part 1
### For Part 1, the user's location is tracked using complex numbers
### Instructions move the user through the complex plane
### The final coordinates are used to generate the solution
function read_doc(file :: String)
    # Read file
    doc = readlines(file)
    # Select string (from Vector{String}, length 1)
    doc = doc[1]
    # Split by ", "
    split_comma(doc) = split(doc, ", ")
    doc |> 
    split_comma .|> # Split by comma e.g., "R1, L3" => ["R1", "L3"]
    String          # Convert Vector{SubString} to Vector{String}
end

struct GPS
    z :: Complex    # Position, real ≡ North / South, imag ≡ West / East
    θ :: Real       # Angle (clockwise) facing from East i.e., 0 ≡ North, π / 2 ≡ West
    function GPS()
        new(0 + 0im, 0)
    end
    function GPS(z, θ)
        new(z, θ)
    end
end

"""
move(position :: GPS, turn :: String, steps :: Real)

Take a starting position on the map, rotate `turn` radians, and move `steps` in the subsequent direction
"""
function move(position :: GPS, instruction :: String)
    # Read direction from `instruction`
    turn_instr = instruction[1]
    turn_dict = Dict('R' => -π / 2, 'L' => π / 2)
    turn = turn_dict[turn_instr]
    
    # Read travel length from `instruction`
    step_instr = instruction[2:length(instruction)]
    steps = parse(Int, step_instr)

    # Move through space
    θ_new = mod2pi(position.θ + turn)
    z_new = position.z + steps * exp(θ_new * 1im)
    GPS(z_new, θ_new)
end

function displacement(position :: GPS)
    abs(real(position.z)) + abs(imag(position.z))
end

file = "Inputs/Day 01.txt"
document = read_doc(file)
position = GPS()
final_position = reduce(move, vcat([position], document))
displacement(final_position) # 146.0

## Part 2
### For Part 2, a change in approach is used
### Instead of tracking a particle (e.g., the user) through the complex plane,
### All integer coordinate pairs will be recorded
### The assumption of integer steps makes intersections easier to identify whilst keeping the problem soluble

abstract type Direction end
struct North <: Direction end
struct South <: Direction end
struct East <: Direction end
struct West <: Direction end

struct Agent
    x :: Integer
    y :: Integer
    dir :: Type
    visited::Vector{Vector{Integer}}
end
Agent() = Agent(0, 0, North, [[0, 0]])
Agent(a::Agent, dir::Type) = Agent(a.x, a.y, dir, a.visited)

function turn(a::Agent, dir::String)
    # Catch error input
    if dir ∉ ["R", "L"] error("dir = '$dir' must be 'L' or 'R' i.e., to turn left or right") end
    # Setup the direction mapping
    # E.g., R gives North => East
    compass = [North, East, South, West]
    right_turn = Dict(zip(compass, circshift(compass, -1)))
    left_turn = Dict(zip(compass, circshift(compass, 1)))
    # Apply turn
    if dir == "R"
        Agent(a, right_turn[a.dir])
    else
        Agent(a, left_turn[a.dir])
    end
end

function move(a::Agent)
    dir = a.dir
    if dir ∈ [North, South]
        Δy = Dict(North => 1, South => -1)[dir]
        y₂ = a.y + Δy
        new_coord = [a.x, y₂]
        Agent(a.x, y₂, dir, vcat(a.visited, [new_coord]))
    else
        Δx = Dict(East => 1, West => -1)[dir]
        x₂ = a.x + Δx
        new_coord = [x₂, a.y]
        Agent(x₂, a.y, dir, vcat(a.visited, [new_coord]))
    end

end

turn_right(a::Agent) = turn(a, "R")
turn_left(a::Agent) = turn(a, "L")

function move(a::Agent, instruction::String)
    # Extract turn instruction
    L_R = instruction[1]
    # Extract number of steps
    n = parse(Int, instruction[2:length(instruction)])
    # Repeat move n times. I.e., [move, move, ..., (n times)]
    move_funcs = repeat([move], n)
    # Identify turn instruction. I.e., turn_right or turn_left
    turn_func = Dict('R' => turn_right, 'L' => turn_left)[L_R]
    # Append turn function
    stepping_funcs = vcat(move_funcs, [turn_func])
    # Apply instructions. I.e. (move ∘ ... ∘ move ∘ turn_func)(a)
    reduce(∘, stepping_funcs)(a)
end

function move(a::Agent, instruction::Vector{String})
    reduce(move, instruction, init = a)
end

function get_multi_visits(a::Agent)
    filter(v -> sum([v == w for w ∈ a.visited]) > 1, a.visited)
end

function get_first_repeat(a::Agent)
    multiple_vists = get_multi_visits(a)
    if length(multiple_vists) >= 1
        multiple_vists[1]
    else
        missing
    end
end

displacement(x::Vector{Integer}) = x .|> abs |> sum

# Illustration

a = Agent() # Agent(0, 0, North, Vector{Integer}[[0, 0]])

a |> turn_left |> move |> move |> turn_right |> move # Agent(-2, 1, North, Vector{Integer}[[0, 0], [-1, 0], [-2, 0], [-2, 1]])

move(a, ["R8", "R4", "R4", "R8"]) |> # Agent(4, 4, North, Vector{Integer}[...])
get_first_repeat |> # [4, 0]
displacement # 4

# Application

file = "Inputs/Day 01.txt"
document = read_doc(file)
move(a, document) |> get_first_repeat |> displacement # 131