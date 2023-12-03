# Part 1

operations = readlines("Inputs/Day 08.txt")

function rect(string::Vector{String})

end

function rotate(string::Vector{String})

end

string = operations[1]
function read_operation(string::String)
    codes = String.(split(string, " "))
    instruction = codes[1]
    parameters = codes[2:end]
    Dict(
        "rect" => rect,
        "rotate" => rotate
    )[instruction](parameters)
end