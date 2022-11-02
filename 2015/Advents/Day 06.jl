# Functions
# Part 1
function match_verb(string::String)::String
    match(r".+?(?= [0-9])", string).match
end
function to_int(coords::String)::Vector{Int}
    split(coords, ",") .|> String .|> str -> parse(Int, str)
end
function reindex(coords::Vector{Int})::Vector{Int}
    coords .+ 1
end
function to_coords(string::String, get_coords::Function)::Vector{Int}
    string |> get_coords |> to_int |> reindex
end
function match_range(string::String, reg::Regex)::Vector{Int}
    get_coords(string) = match(reg, string).match |> String
    string |> str -> to_coords(str, get_coords)
end
function match_bl(string::String)::Vector{Int}
    match_range(string, r"[0-9]+,[0-9]+")
end
function match_tr(string::String)::Vector{Int}
    match_range(string, r"[0-9]+,[0-9]+$")
end
function build_lights()::Matrix{Int}
    zeros(Int, 1000, 1000)
end
function turn_on(lights::Matrix{Int}, x_range::Vector{Int}, y_range::Vector{Int})::Matrix{Int}
    lights[x_range[begin]:x_range[end], y_range[begin]:y_range[end]] .= 1
    lights
end
function turn_off(lights::Matrix{Int}, x_range::Vector{Int}, y_range::Vector{Int})::Matrix{Int}
    lights[x_range[begin]:x_range[end], y_range[begin]:y_range[end]] .= 0
    lights
end
function toggle(lights::Matrix{Int}, x_range::Vector{Int}, y_range::Vector{Int})::Matrix{Int}
    toggle_dict = Dict(0 => 1, 1 => 0)
    toggle_light(light) = toggle_dict[light]
    lights[x_range[begin]:x_range[end], y_range[begin]:y_range[end]] = lights[x_range[begin]:x_range[end], y_range[begin]:y_range[end]] .|> toggle_light
    lights
end
function process(string::String)::Dict{String, Any}
    verb_map = Dict("turn on" => turn_on, "turn off" => turn_off, "toggle" => toggle)
    verb = verb_map[string |> match_verb]
    bl = string |> match_bl
    tr = string |> match_tr
    Dict("verb" => verb, "bl" => bl, "tr" => tr)
end
function apply_instruction(lights::Matrix{Int}, instruction::Dict{String, Any})::Matrix{Int}
    x_range = [instruction["bl"][begin], instruction["tr"][begin]]
    y_range = [instruction["bl"][end], instruction["tr"][end]]
    instruction["verb"](lights, x_range, y_range)
end
function beat_neighbours(instructions::Vector{Dict{String, Any}})::Matrix{Int}
    reduce(apply_instruction, instructions, init = build_lights())
end
## Part 2
function turn_on_fixed(lights::Matrix{Int}, x_range::Vector{Int}, y_range::Vector{Int})::Matrix{Int}
    lights[x_range[begin]:x_range[end], y_range[begin]:y_range[end]] .+= 1
    lights
end
function turn_off_fixed(lights::Matrix{Int}, x_range::Vector{Int}, y_range::Vector{Int})::Matrix{Int}
    lights[x_range[begin]:x_range[end], y_range[begin]:y_range[end]] = max.(0, lights[x_range[begin]:x_range[end], y_range[begin]:y_range[end]] .- 1)
    lights
end
function toggle_fixed(lights::Matrix{Int}, x_range::Vector{Int}, y_range::Vector{Int})::Matrix{Int}
    lights[x_range[begin]:x_range[end], y_range[begin]:y_range[end]] .+= 2
    lights
end
function process_fixed(string::String)::Dict{String, Any}
    verb_map = Dict("turn on" => turn_on_fixed, "turn off" => turn_off_fixed, "toggle" => toggle_fixed)
    verb = verb_map[string |> match_verb]
    bl = string |> match_bl
    tr = string |> match_tr
    Dict("verb" => verb, "bl" => bl, "tr" => tr)
end

# Read
instructions = read("2015/Input/Day 06.txt", String) |> char -> split(char, "\r\n") .|> String
# Part 1
instructions .|> process |> beat_neighbours |> sum
# Part 2
instructions .|> process_fixed |> beat_neighbours |> sum