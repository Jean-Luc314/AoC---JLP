# Part 1
using SplitApplyCombine
using StatsBase
function most_frequent(v::Vector)
    counts = countmap(v)
    unique_values = keys(counts)
    frequencies = values(counts)
    max_frequency = maximum(frequencies)
    invert_counts = Dict(frequencies .=> unique_values)
    invert_counts[max_frequency]
end
correct_error_max(signals) = signals .|> collect |> invert .|> most_frequent |> join

signals = readlines("Inputs/Day 06.txt")
correct_error_max(signals) # mlncjgdg

# Part 2
function least_frequent(v::Vector)
    counts = countmap(v)
    unique_values = keys(counts)
    frequencies = values(counts)
    min_frequency = minimum(frequencies)
    invert_counts = Dict(frequencies .=> unique_values)
    invert_counts[min_frequency]
end
correct_error_min(signals) = signals .|> collect |> invert .|> least_frequent |> join

correct_error_min(signals) # bipjaytb