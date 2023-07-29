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

## Part 2
get_encrypted_name_full(room) = room |> split_dash |> remove_last |> x -> join(x, "-")
function rotate(char::Char, n::Integer)
    num_to_char = Dict(1:26 .=> 'a':'z')
    char_to_num = Dict('a':'z' .=> 1:26)
    if char == '-'
        ' '
    else
        num = char_to_num[char]
        num = mod(num + n, 26)
        if num == 0 num = 25 end
        num_to_char[num]
    end
end
decrypt(room_encrypted::String) = room_encrypted |> collect .|> rotate |> join
function get_real_name(room)
    sector_id = get_numeric(room)
    rotate_n(char::Char) = rotate(char, sector_id)
    room |> get_encrypted_name_full |> collect .|> rotate_n |> join    
end

sector_ids = get_numeric.(room_list)

sector_ids[get_real_name.(room_list).== "northpole object storage"]