
as_integer(x::String) = parse(Int64, x)

parse_numbers(x::String) = as_integer.(String.(split(x, " ")))

x_raw = readlines("2023/Inputs/Day 09.txt")

x_all = parse_numbers.(x_raw)
x = x_all[1]

function predict(x, Σ = 0)
    dx = diff(x)
    x_last = last(x)
    prediction = Σ + x_last

    if all(dx .== 0)
        prediction
    else
        predict(dx, prediction)
    end
end

x = [0, 3, 6, 9, 12, 15]

predict(x)

