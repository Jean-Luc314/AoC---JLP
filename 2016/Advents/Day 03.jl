# Part 1

l = readlines("Inputs/Day 03.txt")

l

remove_blanks(l) = filter(!isempty, l)
parse_int(v) = map(n -> parse(Int, n), v)

function istriangle(sides)
    ranked = sort(sides)
    sum(ranked[1:2]) > ranked[3]
end

l .|> (str -> split(str, " ") .|> String) .|> remove_blanks .|> parse_int .|> istriangle |> sum # 917

# Part 2
# Failed attempts / potential misunderstanding of question
remove_space₂(l) = collect(l)[mod.((1:end) .- 1, 5) .> 1]
fix₀(str) = if str == ' ' '0' else str end
collect_Δ(l) = reduce((L, i) -> vcat(L, [l[(1:3) .+ 3 * (i - 1)]]), 1:Int(length(l) / 3), init = [])
reduce(*, l) |> remove_space₂ .|> fix₀ |> parse_int |> collect_Δ .|> istriangle |> sum

cols = vcat(3:5, 8:10, 13:15)
get_column(i, l = l) = map(Δ -> Δ[i], l)

reduce(vcat, cols .|> get_column) .|> fix₀ |> parse_int |> collect_Δ .|> istriangle |> sum

get_column₁(l) = l[[3, 8, 13]]
get_column₂(l) = l[[4, 9, 14]]
get_column₃(l) = l[[5, 10, 15]]

fix₀(str) = map(c -> if c == ' ' '0' else c end, collect(str))
vcat(get_column₁.(l), get_column₂.(l), get_column₃.(l)) .|> fix₀ .|> parse_int .|> istriangle |> sum # 1936