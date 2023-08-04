# Part 1
using SplitApplyCombine
using StatsBase

signals = readlines("Inputs/Day 06.txt")


function most_frequent(v::Vector)
    counts = countmap(v)
    unique_values = keys(counts)
    frequencies = values(counts)
    max_frequency = maximum(frequencies)
    invert_counts = Dict(frequencies .=> unique_values)
    invert_counts[max_frequency]
end

correct_error(signals) = signals .|> collect |> invert .|> most_frequent |> join

correct_error(signals) # mlncjgdg

# Part 2
