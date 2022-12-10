alphabet() = collect('A':'Z')
struct Stacks
    indices :: Int
    itinerary :: Dict{Int, Vector{Char}}
end
struct Instruction
    move :: Int
    from :: Int
    to :: Int
end
function Stacks(input::Vector{String})::Stacks
    function get_Crates(i::Int, crates_list::Vector{String})::Vector{Char}
        get_Crate(row::String) = row[4i - 2]
        is_blank(crate::Char) = crate == ' '
        crates_list .|> get_Crate |> x -> filter(!is_blank, x)
    end
    indices = 9
    crate_terminate = 8
    index = 1:indices
    crates_list = input[1:crate_terminate]
    cargo_list = index .|> i -> get_Crates(i, crates_list)
    Stacks(indices, Dict(zip(index, cargo_list)))
end
function Instruction(instruct::String)::Instruction
    match_type(type) = parse(Int, match(Regex("(?<=$type )[0-9]*"), instruct).match)
    Instruction(match_type("move"), match_type("from"), match_type("to"))
end
function Instruction(input::Vector{String})::Vector{Instruction}
    filter_not_empty(x) = filter(y -> y != "", x)
    filter_is_move(x) = filter(y -> y[begin] == 'm', x)
    input |> filter_not_empty |> filter_is_move .|> Instruction
end
function move_9000(stack::Stacks, instruct::Instruction)::Stacks
    for i in 1:instruct.move
        prepend!(stack.itinerary[instruct.to], popfirst!(stack.itinerary[instruct.from]))
    end
    stack
end
function move_9001(stack::Stacks, instruct::Instruction)::Stacks
    prepend!(stack.itinerary[instruct.to], stack.itinerary[instruct.from][1:instruct.move])
    deleteat!(stack.itinerary[instruct.from], 1:instruct.move)
    stack
end
function move(stack::Stacks, instruct::Vector{Instruction}, f::Function)::Stacks
    for i in instruct
        f(stack, i)
    end
    stack
end
function get_arrangement(stack::Stacks)::String
    message = ""
    for i in 1:stack.indices
        message *= first(stack.itinerary[i])
    end
    message
end
function get_arrangement(input::Vector{String}, crane::Function)::String
    move(Stacks(input), Instruction(input), crane) |> get_arrangement
end

part1() = get_arrangement(readlines("2022/Inputs/Day 05.txt"), move_9000)
part2() = get_arrangement(readlines("2022/Inputs/Day 05.txt"), move_9001)
part1() # FCVRLMVQP
part2() # RWLWGJGFD