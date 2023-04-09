# Day 01
## Part 1
### For Part 1, the user's location is tracked using complex numbers
### Instructions move the user through the complex plane
### The final coordinates are used to generate the solution
 
# Split to Vector. E.g., "R1, L3, R1" => ["R1", "L3", "R1]
split_comma(doc) = String.(split(doc, ", "))
# Read inputs
read_inputs = split_comma ∘ readline

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
move(position :: GPS, instruction :: String)

Take a starting position on the map, rotate `turn` radians, and move `n` in the subsequent direction
"""
function move(position :: GPS, instruction :: String)
    # Read direction from `instruction`
    turn_instr = instruction[1]
    turn_dict = Dict('R' => -π / 2, 'L' => π / 2)
    turn = turn_dict[turn_instr]
    
    # Read travel length from `instruction`
    n = parse(Int, chop(instruction, head = 1, tail = 0))

    # Move through space
    θ_new = mod2pi(position.θ + turn)
    z_new = position.z + n * exp(θ_new * 1im)
    GPS(z_new, θ_new)
end

function displacement(position :: GPS)
    abs(real(position.z)) + abs(imag(position.z))
end

file = "Inputs/Day 01.txt"
document = read_inputs(file)
position = GPS()
final_position = reduce(move, vcat([position], document))
displacement(final_position) # 146.0

## Part 2
### For Part 2, a change in approach is used
### Instead of tracking a particle (e.g., an agent) through the complex plane,
### The integer coordinate pairs traversed are recorded
### The assumption of integer steps makes intersections easier to identify whilst keeping the problem soluble

abstract type Direction end
struct North <: Direction end
struct South <: Direction end
struct East <: Direction end
struct West <: Direction end

mutable struct Agent
    P::Vector{Integer}
    facing::Type
    visited::Vector{Vector{Integer}}
end

Agent() = Agent([0, 0], North, [[0, 0]])

function turn!(agent::Agent, LR::String)
    # Catch error input
    if LR ∉ ["R", "L"] error("LR = '$LR' must be 'L' or 'R' i.e., to turn left or right") end
    # Setup the direction mapping
    # E.g., "R" gives North => East
    compass = [North, East, South, West]
    rt = Dict(zip(compass, circshift(compass, -1)))
    lt = Dict(zip(compass, circshift(compass, 1)))
    # Apply turn
    agent.facing = Dict("R" => rt[agent.facing], "L" => lt[agent.facing])[LR]
    agent
end

turn_right!(agent::Agent) = turn!(agent, "R")
turn_left!(agent::Agent) = turn!(agent, "L")

function move!(agent::Agent)
    # Get direction agent is facing e.g., North
    facing = agent.facing
    # Calculate change in x & y
    Δx = Dict(North => 0, South => 0, East => 1, West => -1)[facing]
    Δy = Dict(North => 1, South => -1, East => 0, West => 0)[facing]
    # Take step
    P₂ = agent.P .+ [Δx, Δy]
    # Update agent
    agent.P = P₂
    append!(agent.visited, [P₂])
    agent
end

function move!(agent::Agent, instruction::String)
    # Extract turn instruction e.g., 'R' or 'L'
    LR = instruction[1]
    # Extract number of steps
    n = parse(Int, chop(instruction, head = 1, tail = 0))
    # Repeat move! n times. I.e., [move!, move!, ..., (n times)]
    moves! = repeat([move!], n)
    # Identify turn! instruction. I.e., turn_right! or turn_left!
    turn! = Dict('R' => turn_right!, 'L' => turn_left!)[LR]
    # Apply instructions. I.e. (move! ∘ ... ∘ move! ∘ turn!)(a)
    (reduce(∘, moves!) ∘ turn!)(agent)
end

move!(agent::Agent, instruction::Vector{String}) = reduce(move!, instruction, init = agent)

get_multi_visits(agent::Agent) = filter(v -> sum(v == w for w ∈ agent.visited) > 1, agent.visited)

function get_first_repeat(agent::Agent)
    multiple_vists = get_multi_visits(agent)
    if length(multiple_vists) >= 1
        multiple_vists[1]
    else
        missing
    end
end

displacement(x::Vector{Integer}) = x .|> abs |> sum

# Illustration

Agent() # Agent(0, 0, North, Vector{Integer}[[0, 0]])

Agent() |> turn_left! |> move! |> move! |> turn_right! |> move! # Agent([-2, 1], North, [[0, 0], [-1, 0], [-2, 0], [-2, 1]])

move!(Agent())

move!(Agent(), ["R8", "R4", "R4", "R8"]) |> # Agent(4, 4, North, Vector{Integer}[...])
get_first_repeat |> # [4, 0]
displacement # 4

# Application

document = read_inputs("Inputs/Day 01.txt")
move!(Agent(), document) |> get_first_repeat |> displacement # 131