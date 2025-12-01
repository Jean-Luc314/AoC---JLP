# AoC 2016 Day 10
# > https://adventofcode.com/2016/day/10

# Read input
# Collect values
# Collect transactions
# Collect outputs
# Iterate all transactions
# Look up which bot holds 61 & 17
# Need to continuously check in case they're compared before the end

instructions = readlines("2016/Inputs/Day 10.txt")

value_codes = filter(s -> startswith(s, "value"), instructions)
bots_codes = filter(s -> startswith(s, "bot"), instructions)

mutable struct Bot
    name::Int64
    high::Int64
    low::Int64
    gives_high_to::Int64
    gives_low_to::Int64
end

function get_value(instruction::String)
    
    # Positive lookbehind to match "value "
    # Positive lookahead to match " goes"
    m = match(r"(?<=value )(\d+)(?= goes)", instruction)

    m.match |> String |> (n -> parse(Int64, n))
    
end

function read_bot_name(instruction::String)
    
    # Positive lookbehind to match "bot "
    m = match(r"(?<=bot )(\d+)", instruction)

    m.match |> String |> (n -> parse(Int64, n))
    
end

value_to_bot_code = Dict(value_codes .|> get_value .=> value_codes .|> read_bot_name)

function Bot(instruction::String)

    high = nothing
    low = nothing

    name = instruction |> read_bot_name

    Bot(name, high, low, gives_high_to, gives_low_to)
end
