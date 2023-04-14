# Part 1
## Define functions up(), down(), left(), right(), to move the users finger
## Use move() to reduce a String of instructions to the final digit, starting at 5
## Use accumulate() to reduce a Vector{String} to the final digit whilst recording each digit and passing to the next set of instructions 
read_ins() = readlines("Inputs/Day 02.txt")

up(x::Integer) = if x > 3 x - 3 else x end
down(x::Integer) = if x < 7 x + 3 else x end
left(x::Integer) = if mod(x, 3) != 1 x - 1 else x end
right(x::Integer) = if mod(x, 3) != 0 x + 1 else x end

function move(init::Integer, i::String)
    # Function to convert instruction character to function e.g., 'U' => up
    translate(direction) = Dict('U' => up, 'D' => down, 'L' => left, 'R' => right)[direction]
    # Map translate() across Vector{Char} 
    # E.g., collect("RRLDU") = ['R', 'R', 'L', 'D', 'U'] => [right, right, left, down, up]
    directions = i |> collect .|> translate
    # Apply instructions e.g., init |> right |> right |> left |> down |> up
    reduce(|>, directions, init = init)
end

get_code(i::Vector{String}) = accumulate(move, i, init = 5)

## Illustration
get_code(["ULL", "RRDDD", "LURDL", "UUUUD"]) # [1, 9, 8, 5]
## Application
read_ins() |> get_code # [6, 5, 5, 5, 6]

# Part 2
## Similar procedure as Part 1, except the new numberpad changes boundary conditions & operations change
## The 'A', 'B', 'C', 'D' are treated as 10:13 in move₂() to simplify calculation
## decode() converts back into original numberpad key e.g., decode.([5, 10]) = [5, 'A']
decode(n::Integer) = Dict(zip(1:13, vcat(1:9, ['A', 'B', 'C', 'D'])))[n]

function up₂(x::Integer)
    if x ∈ [3, 13]
        x - 2
    elseif x ∉ [5, 2, 1, 4, 9]
        x - 4
    else
        x
    end
end
function down₂(x::Integer)
    if x ∈ [1, 11]
        x + 2
    elseif x ∉ [5, 10, 13, 12, 9]
        x + 4
    else
        x
    end
end
left₂(x::Integer) = if x ∉ [1, 2, 5, 10, 13] x - 1 else x end
right₂(x::Integer) = if x ∉ [1, 4, 9, 12, 13] x + 1 else x end

function move₂(init::Integer, i::String)
    translate(direction) = Dict('U' => up₂, 'D' => down₂, 'L' => left₂, 'R' => right₂)[direction]
    directions = i |> collect .|> translate
    reduce(|>, directions, init = init)
end

get_code₂(i::Vector{String}) = accumulate(move₂, i, init = 5)

## Illustration
["ULL", "RRDDD", "LURDL", "UUUUD"] |> get_code₂ .|> decode # [5, 'D', 'B', 3]
## Application
read_ins() |> get_code₂ .|> decode # ['C', 'B', 7, 7, 9]