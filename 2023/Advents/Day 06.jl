parse_number(string) = parse(Int, string)

function read_values(input)
    values = split(input, r"\s+")[2:end]
    parse_number.(values)
end

function exclude_equality(x, f, g)
    x == f(x) ? g(x) : f(x)
end

"""
    get_record_times(time, distance)

Calculate the integer times that would produce a record distance.

T = Time of race = input

D = Record distance = input

t = Time held charging = variable to solve

T - t = Time moving

Distance = speed * (T - t) & speed = t ⇒ Distance = t * (T - t)

Solve: t * (T - t) > D

t^2 - T * t + D < 0

Giving

t_{1 2} = frac {-T pm sqrt{ T^2 - 4 D }} {2}

# Arguments
- `time`: The time that the race will last.
- `distance`: The minimum, exclusive, distance required to achieve a record.

# Returns
- The range of times that beat the previous record `distance`.

# Examples
```julia
julia> get_record_times(7, 9)
2:5
```
"""
function get_record_times(time, distance)
    Δ = sqrt( time^2 - 4 * distance )
    t₁ = (time - Δ) / 2
    t₂ = (time + Δ) / 2
    exclude_equality(t₁, ceil, x -> x + 1) : exclude_equality(t₂, floor, x -> x - 1)
end

# Part 1
race_input = readlines("2023/Inputs/Day 06.txt")
times     = read_values(race_input[1])
distances = read_values(race_input[2])

map(get_record_times, times, distances) .|> length |> prod # 303600

# Part 2
time = parse_number(filter(isdigit, race_input[1]))
distance = parse_number(filter(isdigit, race_input[2]))
get_record_times(time, distance) |> length # 23654842
