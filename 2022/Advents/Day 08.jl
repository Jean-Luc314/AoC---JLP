
struct Grid
    heights::Matrix{Int64} # COMBAK: enforce nxn
end

heights(grid::Grid) = grid.heights

Base.size(grid::Grid) = size(heights(grid), 2)

slice_row(grid::Grid, row::Integer) = grid.heights[row, :]
slice_col(grid::Grid, col::Integer) = grid.heights[:, col]

hmax(grid::Grid, row::Integer) = maximum(slice_row(grid, row))

function hmax(grid::Grid)
    nrow = size(grid)
    1:nrow .|> r -> hmax(grid, r)
end

vmax(grid::Grid, col::Integer) = maximum(slice_col(grid, col))

function vmax(grid::Grid)
    ncol = size(grid)
    1:ncol .|> c -> vmax(grid, c)
end

split_str(string::String) = String.(split(string, ""))

parse_int(string::String) = parse(Int, string)
parse_int(string::Vector{String}) = parse_int.(string)

as_matrix(v::Vector{Vector{Int64}}) = reduce(hcat, v)

function frow(grid::Grid, f::Function)
    nrow = size(grid)
    get_row_max(i::Int64) = f(v[i,:])
    1:nrow .|> get_row_max |> hcat
end

function fcol(v::Matrix{Int64}, f::Function)
    dims = size(v, 2)
    get_row_max(i::Int64) = f(v[:, i])
    1:dims .|> get_row_max |> hcat |> transpose
end

function lookright(v::Matrix{Int64})
    
end

rowmax(v::Matrix{Int64}) = frow(v, maximum)
colmax(v::Matrix{Int64}) = fcol(v, maximum)

inputs = readlines("2022/Inputs/Day 08.txt")

example = ["30373", "25512", "65332", "33549", "35390"]

grid = example .|> split_str .|> parse_int |> as_matrix |> Grid

grid .- hmax(grid, 1)
grid .- colmax(grid)

v

