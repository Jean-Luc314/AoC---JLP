struct ID_Range
    min :: Int
    max :: Int
end
struct Pair
    elf_1 :: ID_Range
    elf_2 :: ID_Range
end
as_ID_Range(range::String)::ID_Range = ID_Range(parse.(Int, String.(split(range, "-")))...)
as_Pair(pair)::Pair = Pair(as_ID_Range.(String.(split(pair, ",")))...)
is_contained(id1::ID_Range, id2::ID_Range)::Bool = (id1.min <= id2.min) & (id1.max >= id2.max)
is_contained(pair::Pair)::Bool = is_contained(pair.elf_1, pair.elf_2) | is_contained(pair.elf_2, pair.elf_1)

part1() = "2022/Inputs/Day 04.txt" |> readlines .|> as_Pair .|> is_contained |> sum
part1()

does_overlap(id1::ID_Range, id2::ID_Range)::Bool = (id1.max >= id2.min) & (id2.max >= id1.min)
does_overlap(pair::Pair)::Bool = does_overlap(pair.elf_1, pair.elf_2) | does_overlap(pair.elf_2, pair.elf_1)

part1() = "2022/Inputs/Day 04.txt" |> readlines .|> as_Pair .|> does_overlap |> sum
part1()