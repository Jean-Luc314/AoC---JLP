# Part 1

instructions = readlines("Inputs/Day 02.txt")

up(x::Integer) = if x > 3 x - 3 else x end
down(x::Integer) = if x < 7 x + 3 else x end
left(x::Integer) = if mod(x, 3) != 1 x - 1 else x end
right(x::Integer) = if mod(x, 3) != 0 x + 1 else x end

function move(init::Integer, instruction::String)
    # Function to convert instruction character to function e.g., 'U' => up
    translate(direction) = Dict('U' => up, 'D' => down, 'L' => left, 'R' => right)[direction]
    # Map translate() across Vector{Char} e.g., "RRLDU" => [right, right, left, down, up]
    directions = map(translate, collect(instruction))
    # Apply instructions e.g., init |> right |> right |> left |> down |> up
    reduce(|>, directions, init = init)
end

get_code(start::Integer, instructions::Vector{String}) = accumulate(move, instructions, init = start)

get_code(5, ["ULL", "RRDDD", "LURDL", "UUUUD"]) # 1985

## Application

get_code(5, instructions) # [6, 5, 5, 5, 6]

instruction = instructions[1]

numberpad = transpose([1:3 4:6 7:9])


# Old attemp at Part 1

# LR and UD are orthogonal, their positions can be tracked separately
# The solution is a plus scan over the array of characters where L, D => -1 and R, U => 1 respectively
# The plus scan will give the net left / right, down / up moves
# This net figure will be capped depending on the starting location e.g., at most ±1 starting at 5

LR(instruction) = reduce(+, map(char -> Dict('L' => -1, 'R' => 1, 'D' => 0, 'U' => 0)[char], collect(instruction)))
DU(instruction) = reduce(+, map(char -> Dict('L' => 0, 'R' => 0, 'D' => -1, 'U' => 1)[char], collect(instruction)))

LRDU(instruction) = [DU(instruction), LR(instruction)]

get_ind(n) = (Tuple ∘ first)(findall(==(n), numberpad))

contract_range(ind) = if ind < 1 1 elseif ind > 3 3 else ind end

function move(n, instruction)
    ind₂ = (CartesianIndex ∘ Tuple)(contract_range.(get_ind(n) .+ LRDU(instruction)))
    numberpad[ind₂]
end

# Need to change the plus scan. Give it an init? needs to shift between -init .+ [-1, 0, 1] where init ∈ -1:1
move(5, "RRL")