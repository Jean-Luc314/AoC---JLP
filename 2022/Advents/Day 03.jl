struct Compartment
    items :: String
end
struct Rucksack
    c_1 :: Compartment
    c_2 :: Compartment
end
function as_Rucksack(contents::String)::Rucksack
    len = Int(length(contents) / 2)
    Rucksack(
        Compartment(contents[begin:len]),
        Compartment(contents[len + 1:end]))
    end
function alphabet()::Vector{Char}
    lower = collect('a':'z')
    upper = collect('A':'Z')
    vcat(lower, upper)
end
function count(comp::Compartment)::Dict{Char, Int}
    record = Dict(zip(alphabet(), zeros(Int, length(alphabet()))))
    for letter in comp.items
        record[letter] += 1
    end
    record
end
function find_error(ruck::Rucksack)::Char
    record_1 = count(ruck.c_1)
    record_2 = count(ruck.c_2)
    for letter in alphabet()
        if (record_1[letter] > 0) & (record_2[letter] > 0)
            return letter
        end
    end
end
function as_priority(letter::Char)::Int
    score_dict = Dict(zip(alphabet(), 1:52))
    score_dict[letter]
end
part1() = "2022/Inputs/Day 03.txt" |> readlines .|> as_Rucksack .|> find_error .|> as_priority |> sum
part1() # 7763

struct Group
    elf_1 :: String
    elf_2 :: String
    elf_3 :: String
end
function as_Group(rucksacks::Vector{String})::Vector{Group}
    len = Int(length(rucksacks) / 3)
    1:len .|> i -> Group(rucksacks[3i - 2], rucksacks[3i - 1], rucksacks[3i])
end
function find_badge(group::Group)::Char
    for letter in alphabet()
        if (letter in group.elf_1) & (letter in group.elf_2) & (letter in group.elf_3)
            return letter
        end
    end
end

part2() = "2022/Inputs/Day 03.txt" |> readlines |> as_Group .|> find_badge .|> as_priority |> sum
part2()