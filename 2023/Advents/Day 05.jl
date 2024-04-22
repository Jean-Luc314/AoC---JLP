# Part 1 Functions

function collapse(sep::String)
    function collapse(string::Vector{String})
        reduce((s1, s2) -> s1 * sep * s2, string)
    end
end

split_space(string::String) = String.(split(string, " "))
split_underscore(string::String) = String.(split(string, "_"))
parse_int(string::String) = parse(Int64, string)

function read_seeds(almanac::String)
    seed_row = String(match(r"(?<=seeds: ).+?(?=__)", almanac).match)
    seed_row |> split_space .|> parse_int
end

function read_almanac_map(almanac::String, source::String, destination::String)
    almanac_string = String(match(Regex("(?<=$(source)-to-$(destination) map:_).*?(?=__)"), almanac).match)
    almanac_vector = almanac_string |> split_underscore .|> split_space .|> (x -> parse_int.(x))
    nth(n) = v -> v[n]
    destination = almanac_vector .|> nth(1)
    source      = almanac_vector .|> nth(2)
    range       = almanac_vector .|> nth(3)
    Dict(
        "destination" => destination,
        "source"      => source,
        "range"       => range
    )
end

add_underscore(string::String) = string * "_"
expand_range(start::Int64, range::Int64) = start .+ (0 : range-1)
is_in_range(source::Int64, destination_range::UnitRange{Int64}) = minimum(destination_range) <= source <= maximum(destination_range)
is_in_range(source::Int64, destination_range::Vector{UnitRange{Int64}}) = [is_in_range(source, d) for d ∈ destination_range]

function get_destination(x_to_y)
    function (x)
        range = x_to_y["range"]
        destination_range = map(expand_range, x_to_y["destination"], range)
        source_range = map(expand_range, x_to_y["source"], range)
        source_in_range = is_in_range(x, source_range)
        if all(source_in_range .== 0)
            x
        else
            distance = x - minimum(source_range[source_in_range][1])
            minimum(destination_range[source_in_range][1]) + distance
        end
    end
end

function get_location(almanac)    
    seed_to_soil            = read_almanac_map(almanac, "seed", "soil")
    soil_to_fertilizer      = read_almanac_map(almanac, "soil", "fertilizer")
    fertilizer_to_water     = read_almanac_map(almanac, "fertilizer", "water")
    water_to_light          = read_almanac_map(almanac, "water", "light")
    light_to_temperature    = read_almanac_map(almanac, "light", "temperature")
    temperature_to_humidity = read_almanac_map(almanac, "temperature", "humidity")
    humidity_to_location    = read_almanac_map(almanac, "humidity", "location")
    function (seed)
        seed |>
            get_destination(seed_to_soil) |>
            get_destination(soil_to_fertilizer) |>
            get_destination(fertilizer_to_water) |>
            get_destination(water_to_light) |>
            get_destination(light_to_temperature) |>
            get_destination(temperature_to_humidity) |>
            get_destination(humidity_to_location)
    end
end

almanac = "2023/Inputs/Day 05.txt" |> readlines |> collapse("_") |> add_underscore |> add_underscore
seeds = read_seeds(almanac)

# Part 1
alamanac_reader = get_location(almanac)
seeds .|> alamanac_reader |> minimum # 836040384

# Part 2
seed_starts = seeds[1:2:end]
seed_ranges = seeds[2:2:end]

seeds = reduce(vcat, collect.(map(expand_range, seed_starts, seed_ranges)))
reduce((x, y) -> min(x, alamanac_reader(y)), seeds; init = maximum(seeds)) # 10834440
