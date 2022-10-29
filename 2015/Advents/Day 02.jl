# Functions
function remove_char(string::String, char::Char = only("\r"))::String
    filter(x -> x != char, string)
end
function to_int(string::SubString)::Int
    parse(Int, string)
end
function to_dims(m::String)::Vector{Int}
    split(m, 'x') .|> to_int
end
function calc_wrapping(dims::Vector{Int})::Int
    l, w, h = dims
    A₁ = l * w
    A₂ = l * h
    A₃ = w * h
    A = [A₁, A₂, A₃]
    area = 2 .* A |> sum
    slack = minimum(A)
    area + slack
end
function calc_ribbon(dims::Vector{Int})::Int
    l, w, h = dims
    L₁ = l + w
    L₂ = h + w
    L₃ = h + l
    L = [L₁, L₂, L₃]
    wrap = 2 * minimum(L)
    bow = prod(dims)
    wrap + bow
end
# Read
measurement_file = read("2015/Input/Day 02.txt", String)
# Part 1
measurements = split(measurement_file, '\n') .|> String .|> remove_char .|> to_dims
measurements .|> calc_wrapping |> sum
# Part 2
measurements .|> calc_ribbon |> sum