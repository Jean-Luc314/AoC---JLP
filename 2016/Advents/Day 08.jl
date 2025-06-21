# AoC 2016 Day 08
# > https://adventofcode.com/2016/day/8

# Part 1
# Follow instructions that manipulate "pixels on a screen"
# Controls:
#   > "rect {col}x{row}" - illuminate a rectangle in the top left corner of the screen
#   > "rotate {axis}={row/col} by {n}" - shift pixels by {n} coordinates (pixels wrap around the screen, left-to-righ and top-to-bottom)

using DataFrames
using DelimitedFiles
using Makie
using CairoMakie

parse_maybe = (type, str) -> if ismissing(str) missing else parse(type, str) end

match_string = (rx, m) -> if occursin(rx, m) String(match(rx, m).match) else missing end

match_int = (rx, m) -> parse_maybe(Int, match_string(rx, m))

function process(message)
    operations = DataFrame(message = message)
    
    transform!(
        operations,
        :message => ByRow(m -> match_string(r"rect|rotate", m)) => :instruction
    )
    transform!(
        operations,
        # For "rotate", increase index by 1 because col=1 is the second column
        [:message, :instruction] => ByRow((m, i) -> if i == "rect" match_int(r"[0-9]+", m) else match_int(r"(?<=x=)[0-9]+", m) + 1 end) => :col,
        [:message, :instruction] => ByRow((m, i) -> if i == "rect" match_int(r"(?<=x)[0-9]+", m) else match_int(r"(?<=y=)[0-9]+", m) + 1 end) => :row,
        [:message, :instruction] => ByRow((m, i) -> if i == "rotate" match_int(r"(?<=by )[0-9]+", m) else missing end) => :by
    )

    operations
end

function rect!(screen, col, row)
    screen[1:row, 1:col] .= "#"
    screen
end

wrap_index(i, n, by) = mod.(i .- 1 .- by, n) .+ 1

function rotate_col!(screen, col, by)
    nrow = size(screen, 1)
    screen[:, col] .= screen[wrap_index(1:nrow, nrow, by), col]
    screen
end

function rotate_row!(screen, row, by)
    ncol = size(screen, 2)
    screen[row, :] .= screen[row, wrap_index(1:ncol, ncol, by)]
    screen
end

function process_pixel!(screen, operations, film = [])
    if isempty(film) push!(film, copy(screen)) end
    # Pop first row
    instructions = popat!(operations, 1)
    if instructions.instruction == "rect"
        rect!(screen, instructions.col, instructions.row)
    elseif (instructions.instruction == "rotate") & !ismissing(instructions.col)
        rotate_col!(screen, instructions.col, instructions.by)
    elseif (instructions.instruction == "rotate") & !ismissing(instructions.row)
        rotate_row!(screen, instructions.row, instructions.by)
    end
    push!(film, copy(screen))
    if size(operations, 1) == 0
        screen
    else
        process_pixel!(screen, operations, film)
    end
end

screen = fill(".", 6, 50)
message = readlines("Inputs/Day 08.txt")

operations = process(message)
film = []

process_pixel!(screen, operations, film)

sum(screen .== "#") # 110

# Part 2
# Export the output - read the message
writedlm("Advents/Day 08 Output.txt", screen,' ') # ZJHRKCPLYJ

# Bonus - Visualise the instructions
## Convert to 1 = "#" and 0 = "."

## List of each screen start to finish
display = map(x -> rotr90(x) .== "#", film)

## Create a gif
fig = Figure(size = (600, 600))
ax = Axis(fig[1, 1], aspect = DataAspect(), title="Advent of Code 2016 Day 08!")
hidedecorations!(ax)
hidespines!(ax)
animated_data = Observable(display[1])

im = image!(animated_data, interpolate = false)

output_gif_path = "Advents/Day 08.gif"
framerate = 15

# Extend final screen for a few seconds so the user can look
# at the final state in the gif
append!(display, fill(display[end], framerate * 3))

record(fig, output_gif_path, 1:length(display); framerate = framerate) do frame_num
    animated_data[] = display[frame_num]
end

