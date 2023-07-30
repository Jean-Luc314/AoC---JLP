# Part 1
using MD5

get_hash(str::String) = str |> md5 |> bytes2hex
isinteresting(str::String) = first(str, 5) == "0" ^ 5
function get_password(door_id::String)
    index = 0
    password = ""
    while length(password) < 8
        door_hash = get_hash(string(door_id, index))
        if isinteresting(door_hash)
            password *= door_hash[6]
        end
        index += 1
    end
    password
end

password = get_password("reyedfim")

# Part 2
function get_password_2(door_id::String)
    index = 0
    password = collect("_" ^ 8)
    seen = []
    while '_' ∈ password
        door_hash = get_hash(string(door_id, index))
        if isinteresting(door_hash)
            position_character = door_hash[6]
            if position_character ∉ 'a':'z'
                position = parse(Int64, position_character)
                if (position < 8) & (position ∉ seen)
                    append!(seen, position)
                    password[position + 1] = door_hash[7]
                end
            end
        end
        index += 1
    end
    password |> join
end

get_password_2("reyedfim") # 863dde27

# Alternative maybe approach
# Use Just & Nothing types to remove the "Pyramid of Doom"
struct Just
    x::Any
end
struct Nothing end

check_interesting(str::Just) = isinteresting(str.x) ? Just(str.x[6]) : Nothing()
check_interesting(str::Nothing) = Nothing()

check_position(char::Just) = char.x ∉ 'a':'z' ? Just(parse(Int64, char.x)) : Nothing()
check_position(char::Nothing) = Nothing()

check_valid_position(int::Just, seen::Vector) = (int.x < 8) & (int.x ∉ seen) ? int.x : Nothing()
check_valid_position(int::Nothing, seen::Vector) = Nothing()

function get_password_m(door_id::String)
    index = 0
    password = collect("_" ^ 8)
    seen = []
    while '_' ∈ password
        door_hash = get_hash(string(door_id, index))
        position = 
            door_hash |>
            Just |>
            check_interesting |>
            check_position |>
            (x -> check_valid_position(x, seen))
        if position != Nothing()
            append!(seen, position)
            password[position + 1] = door_hash[7]
        end
        index += 1
    end
    password |> join
end

get_password_m("reyedfim")

# Time test
function test(method, door_id)
    t = @timed method(door_id)
    t[:time]
end

n = 5
time_2 = test.(repeat([get_password_2], n), "reyedfim") # 11.553284 seconds
time_m = test.(repeat([get_password_m], n), "reyedfim") # 11.898812 seconds

mean(v) = sum(v) / length(v)
time_2 |> mean
time_m |> mean
