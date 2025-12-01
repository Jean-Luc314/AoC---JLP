# AoC 2025 Day 01
# > https://adventofcode.com/2025/day/1

# L => -, R => +
# If x < 0, 100 + x
# If x > 99, x - 100
# Only need to modulo at the very end
# Function to reduce
# Function to recurse down to [0, 100]

function get_direction(string::String)::Char
    string[1]
end

function translate_to_sign(string::Char)::Function
        Dict('L' => -, 'R' => +)[string]
end

function parse_number(str::String)::Int64
    parse(Int64, str)
end

function get_step(string::String)::Int64
    match(r"\d+", string).match |> String |> parse_number
end

function dial_safe(position::Int64, by::Int64, Direction::Function)::Int64
    Direction(position, by)
end

function dial_safe(position::Int64, by::Vector{Int64}, Direction::Vector{Function}, log::Vector{Int64} = Int64[])::Vector{Int64}

    if length(by) > 0
        # Move the dial
        new_positon = dial_safe(position[1], by[1], Direction[1])
        # Add the new position to the log
        push!(log, new_positon)
        # Redial
        dial_safe(new_positon, by[2:end], Direction[2:end], log)
    else
        log
    end

end

function get_password(positions::Vector{Int64})::Int64
    sum(positions .== 0)
end

function count_clicks(raw_positions::Vector{Int64}, clicks::Int64 = 0)
    
    next = popfirst!(raw_positions)
    
    count_clicks_rotation = div(next, 100)
    
    clicks += abs(count_clicks_rotation)
    
    raw_positions .-= count_clicks_rotation * 100
    
    if -100 < next - count_clicks_rotation * 100 < 0
        clicks += 1
        raw_positions .+= 100
    end

    if length(raw_positions) == 0
        clicks
    else
        count_clicks(raw_positions, clicks)
    end
end

instructions = readlines("2025/Inputs/2025 Day 01.txt")

start = 50

# Vector of [+, -]
signs = instructions .|> get_direction .|> translate_to_sign

# Vector of steps to rotate. E.g., [5, 10, 0, ...]
steps = instructions .|> get_step

# Vector of all dials recorded before return to range [0, 100)
raw_positions = dial_safe(start, steps, signs)

# Bring all values to range [0, 100)
positions = mod.(raw_positions, 100)

# Part 1: Count zeros
get_password(positions) # 999

# Part 2: Count number of times zero is passed
raw_positions |> copy |> count_clicks # 6099

