using DataFrames

# Part 1
remove_last(v::Vector) = v[1:end-1]
split_dash(str::String) = String.(split(str, "-"))
get_encrypted_name = join ∘ remove_last ∘ split_dash
function get_counts(encrypted_name)
    letters = collect(encrypted_name)
    unique_letters = unique(letters)
    counts = unique_letters .|> (x -> sum(x .== letters))
    DataFrame(counts = counts, unique_letters = unique_letters)
end
sort_letters(df) = sort(df, [order(:counts, rev = true), order(:unique_letters)])
pull(df) = df.unique_letters
taper(v) = v[1:5]
get_checksum = taper ∘ join ∘ pull ∘ sort_letters ∘ get_counts ∘ get_encrypted_name
get_checksum_provided(room) = match(r"(?<=\[).*(?=\])", room).match
get_numeric(string::String) = parse(Int64, filter(isnumeric, string))
is_valid_room(room::String) = get_checksum(room) == get_checksum_provided(room)
count_valid_id(room_list::Vector{String}) = sum(get_numeric.(room_list)[is_valid_room.(room_list)])


room_list = readlines("Inputs/Day 04.txt")
count_valid_id(room_list) # 278221

