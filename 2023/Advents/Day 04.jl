# Part 1 Functions
struct Scratchcard
    card::Integer
    winning::Vector{Integer}
    numbers::Vector{Integer}
end
parse_int(string::String) = parse(Int64, string)

function get_card(scratchcard::String)
    card = match(r"[0-9]+(?=:)", scratchcard).match
    card |> String |> parse_int
end

get_card(scratchcard::Scratchcard) = scratchcard.card

deduplicate_spaces(string::String) = replace(string, r" +" => " ")

split_space(string::String) = String.(split(string, " "))

function get_winning(scratchcard::String)
    winning = String(match(r"(?<=: ).+(?= \|)", scratchcard |> deduplicate_spaces).match)
    winning |> split_space .|> parse_int
end

get_winning(scratchcard::Scratchcard) = scratchcard.winning

function get_numbers(scratchcard::String)
    numbers = String(match(r"(?<=\| ).+", scratchcard |> deduplicate_spaces).match)
    numbers |> split_space .|> parse_int
end

get_numbers(scratchcard::Scratchcard) = scratchcard.numbers

Scratchcard(scratchcard::String) = Scratchcard(get_card(scratchcard), get_winning(scratchcard), get_numbers(scratchcard))

function filter_winning(scratchcard::Scratchcard)
    winning = get_winning(scratchcard)
    numbers = get_numbers(scratchcard)
    is_winning(n::Integer) = n ∈ winning
    filter(is_winning, numbers)
end

count_points(winning::Vector{Integer}) = if winning == Integer[] 0 else 2 ^ (length(winning) - 1) end

scratchcards = "2023/Inputs/Day 04.txt" |> readlines .|> Scratchcard

# Part 1
scratchcards .|> filter_winning .|> count_points |> sum # 23441

# Part 2 Functions
count_winning(scratchcard::Scratchcard) = scratchcard |> filter_winning |> length

function copy_card!(instances::Integer)
    function copy_card!(scratchpile_counts::Dict{Int64, Int64}, id::Integer)
        scratchpile_counts[id] += instances
        scratchpile_counts
    end
end

function process(scratchcards::Vector{Scratchcard})
    scratchcard_ids = get_card.(scratchcards)
    scratchpile = Dict(scratchcard_ids .=> scratchcards)
    scratchpile_counts = Dict(scratchcard_ids .=> 1)
    function process!(scratchpile_counts::Dict{Int64, Int64}, id::Integer = 1)
        n = count_winning(scratchpile[id])
        instances = scratchpile_counts[id]
        reduce(copy_card!(instances), id .+ (1:n), init = scratchpile_counts)
    end
    reduce(process!, scratchcard_ids, init = scratchpile_counts)
end

# Part 2
scratchcards |> process |> values |> sum # 5923918