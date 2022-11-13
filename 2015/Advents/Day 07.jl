# Functions
function pad(x::Vector{Int}, output_len::Int)::Vector{Int}
    pad_len = output_len - length(x)
    zeros(Int, pad_len)
    prepend!(x, zeros(Int, pad_len))
end
function to_bit(x::Vector{Int})::Vector{Vector{Int}}
    pad_max(x) = pad(x, 16)
    digits.(x, base = 2) .|> reverse .|> pad_max
end
function to_bit(x::Int)::Vector{Int}
    pad_max(x) = pad(x, 16)
    digits(x, base = 2) |> reverse |> pad_max
end
function to_dec(x::Vector{Int})::Int
    n = length(x) - 1
    bases = 2 .^ (n:-1:0)
    sum(x .* bases)
end
function construct_gate(truth_table::Dict{Tuple{Int, Int}, Int})::Function
    function gate(x::Int, y::Int)::Int
        map_truth(bits) = [truth_table[z] for z in zip(bits...)]
        [x, y] |> to_bit |> map_truth |> to_dec
    end
    gate
end
function NOT(x::Vector{Int})::Int
    truth_table = Dict(0 => 1, 1 => 0)
    map_truth(bits) = truth_table[bits]
    x[2] |> to_bit .|> map_truth |> to_dec
end
function AND(x::Vector{Int})::Int
    truth_table = Dict((0, 0) => 0, (0, 1) => 0, (1, 0) => 0, (1, 1) => 1)
    construct_gate(truth_table)(x[1], x[2])
end
function OR(x::Vector{Int})::Int
    truth_table = Dict((0, 0) => 0, (0, 1) => 1, (1, 0) => 1, (1, 1) => 1)
    construct_gate(truth_table)(x[1], x[2])
end
function LSHIFT(x::Vector{Int})::Int
    x[1] * 2^x[2]
end
function RSHIFT(x::Vector{Int})::Int
    floor(x[1] * 1 / 2^x[2]) |> Int
end
function NO_OP(x::Vector{Int})::Int
    x[2]
end

function NOT(x::Vector{Union{Nothing, Int}})::Int
    truth_table = Dict(0 => 1, 1 => 0)
    map_truth(bits) = truth_table[bits]
    x[2] |> to_bit .|> map_truth |> to_dec
end
function AND(x::Vector{Union{Nothing, Int}})::Int
    truth_table = Dict((0, 0) => 0, (0, 1) => 0, (1, 0) => 0, (1, 1) => 1)
    construct_gate(truth_table)(x[1], x[2])
end
function OR(x::Vector{Union{Nothing, Int}})::Int
    truth_table = Dict((0, 0) => 0, (0, 1) => 1, (1, 0) => 1, (1, 1) => 1)
    construct_gate(truth_table)(x[1], x[2])
end
function LSHIFT(x::Vector{Union{Nothing, Int}})::Int
    x[1] * 2^x[2]
end
function RSHIFT(x::Vector{Union{Nothing, Int}})::Int
    floor(x[1] * 1 / 2^x[2]) |> Int
end
function NO_OP(x::Vector{Union{Nothing, Int}})::Int
    x[2]
end
# Plan
## Dict of known variables
## Dict of variables to be calculated, constructs the operation to be performed e.g. b = a RSHIFT 2
## Cycle through unknown variables, if all inputs knowable then calculate and assign to the known Dict
function interpret(codes::Dict{String, String})::Dict{String, Any}
    function read_instruction(input::String)::Dict{String, Any}
        remove_space(str) = filter(!isspace, str)
        operators = ["NOT", "OR", "AND", "LSHIFT", "RSHIFT", "NO_OP"]
        op_lookup = Dict(zip(operators, [NOT, OR, AND, LSHIFT, RSHIFT, NO_OP]))
        if occursin.(operators, input) |> !any
            operator = "NO_OP"
            args = ["", input]
        else
            operator = filter(op -> occursin(op, input), operators)[1]
            args = split(input, operator) .|> String .|> remove_space
        end
        Dict("op" => op_lookup[operator], "args" => args)
    end
    Dict(zip(codes |> keys, codes |> values .|> read_instruction))
end
function process(instructions::Vector{String})::Dict{String, String}
    get_val(code) = split(code, " -> ")[begin] |> String
    get_var(code) = split(code, " -> ")[end] |> String
    values = instructions .|> get_val
    vars = instructions .|> get_var
    Dict(zip(vars, values))
end
function get_known(instructions::Vector{String})::Dict{String, Int}
    known_filter(codes) = codes |> values .|> x -> tryparse(Int, x.second) .|> !isnothing
    inputs = filter(known_filter, instructions |> process)
    vars = inputs |> keys
    vals = inputs |> values .|> x -> parse(Int, x)
    Dict(zip(vars, vals)) 
end
function filter_found(codes::Dict{String, String}, known_codes::Dict{String, Int})::Dict{String, String}
    filter(p -> p.first ∉ keys(known_codes), codes)
end
function eval_arg(arg::Int, known_codes::Dict{String, Int})::Int
    arg
end
function is_int(str::String)::Bool
    tryparse(Int, str) |> !isnothing
end
function eval_arg(arg::String, known_codes::Dict{String, Int})::Union{Int, Nothing}
    if is_int(arg)
        parse(Int, arg)
    else
        arg == "" ? nothing : known_codes[arg]
    end
end
function check_arg_known(arg::Union{Int, String}, known_codes::Dict{String, Int})::Bool
    (arg ∈ keys(known_codes)) | (arg |> is_int) | (arg == "")
end
function join_circuit(codes::Dict{String, Any}, known_codes::Dict{String, Int})
    codes = copy(codes)
    known_codes = copy(known_codes)
    while length(codes) > 0
        for key ∈ codes |> keys
            args = codes[key]["args"]
            if (args .|> arg -> check_arg_known(arg, known_codes)) |> all
                op = codes[key]["op"]
                known_codes[key] = op(args .|> x -> eval_arg(x, known_codes))
                delete!(codes, key)
            end
        end
    end
    known_codes
end
# Read
instructions = read("2015/Input/Day 07.txt", String) |> char -> split(char, "\r\n") .|> String
# Part 1
known_codes = instructions |> get_known
codes = filter_found(instructions |> process, known_codes) |> interpret
circuit = join_circuit(codes, known_codes)
a = circuit["a"]
# Part 2
known_codes["b"] = a
circuit = join_circuit(codes, known_codes)
circuit["a"]