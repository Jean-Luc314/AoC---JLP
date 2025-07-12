# AoC 2016 Day 09
# > https://adventofcode.com/2016/day/9

using DataFrames
using Plots
using Format

# Functions

match_int(reg, str) = parse(Int, String(match(reg, str).match))

detect_markers(pile) = !(match(r"\((\d+)x(\d+)\)", pile) === nothing)

format_with_commas(val) = format(val, commas=true, precision=0)

function process_pile(pile)
    
    df = DataFrame(len = Int64[], rep = Int64[], rep_raw = String[], pattern = String[])
    
    while pile != ""
        
        # Check pile contains markers
        @assert detect_markers(pile)
        
        rep_raw = match(r"\((\d+)x(\d+)\)", pile).match
        
        len = match_int(r"(\d)+", pile)
        rep = match_int(r"(?<=x)(\d)+", pile)
        
        # Remove the marker and the pattern from the pile
        pile = replace(pile, r"\(\d+x\d+\)" => "", count = 1)
        
        # Extract the pattern to be repeated
        pattern = pile[1:len]
        
        # Remove the pattern from the pile
        pile = pile[len+1:end]
        
        # Add to collection
        push!(df, (len, rep, rep_raw, pattern)), pile
        
        # Extract any patterns before the next marker
        if !isempty(pile) && pile[1] != '('
            remainder = match(r".+?(?=\()", pile).match
            remainder_len = length(remainder)
            
            pile = pile[remainder_len+1:end]
            
            push!(df, (remainder_len, 1, "", remainder))
        end
        
    end
    
    # Check len field
    @assert all(length.(df.pattern) .== df.len)
    
    # Calculate the decomposed length
    transform!(df, [:len, :rep] => ByRow(*) => :dec_len)
    
end

# Breadth First Search algorithm
function bfs(node::Vector, recurse::Function, search::Function)
    while recurse(node)
        node = search(node)
    end
    node
end

# Use process_pile() to split pile into markers and patterns
# Then, count accumulate the number of repetitions and store the pattern
# in node = (n, pile)
function decompress(node::Tuple{Int64, String})::Vector{Tuple{Int64, String}}
    n = node[1]
    pile = node[2]
    if !detect_markers(pile)
        [node]
    else
        df = process_pile(pile)
    
        map((x, y) -> (x, y), df.rep .* n, df.pattern)
    end
end

# Function factory to use algorithm to expand the queue using
# [n1, ..., nn] .-> [algorithm(n1), ..., algorithm(nn)]
# Flatten to single dimensional vector of nodes
# Return function for the bfs()
function search(algorithm::Function)::Function
    
    function f(node::Vector)::Vector
        
        vcat(algorithm.(node)...)

    end

    f

end

# Predicate - decide whether there are more markets to search
recurse(node::Vector{Tuple{Int64, String}})::Bool = any(map(n -> detect_markers(n[2]), node))

# Count the total decompressed length
aggregate(node::Vector{Tuple{Int64, String}}) = sum(map(n -> n[1] * length(n[2]), node))

# Part 1

pile = readlines("Inputs/Day 09.txt")[1]

df = process_pile(pile)

sum(df.dec_len) # 115118

# Part 2
decompression = bfs([(1, pile)], recurse, search(decompress))
aggregate(decompression) # 11107527530

# Bonus - distribution of characters

decompression_df = DataFrame(n = map(n -> n[1], decompression), string = map(n -> n[2], decompression))

alphabet = collect('A':'Z')

function count_letters(l)
    sum(map(str -> l in str, decompression_df.string) .* decompression_df.n)
end

letter_counts = DataFrame(letter = alphabet, n = map(count_letters, alphabet))

bar_chart = bar(
    letter_counts.letter,
    letter_counts.n,
    title = "Letter Count in Decompressed Message",
    xlabel = "Letter",
    ylabel = "Count",
    legend = false,
    color = :lightblue,
    yformatter = format_with_commas
)
