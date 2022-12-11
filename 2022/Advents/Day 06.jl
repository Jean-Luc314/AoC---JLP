get_input() = readlines("2022/Inputs/Day 06.txt")[1]
function detect_packet(n::Int)
    function detect_marker(datastream::String)
        i = n - 1
        marker_found = false
        while !marker_found
            i += 1
            prior = datastream[i - n + 1:i]
            marker_found = length(unique(prior)) == length(prior)
        end
        i
    end
    detect_marker
end
part1() = get_input() |> detect_packet(4)
part1() # 1287
part2() = get_input() |> detect_packet(14)
part2() # 3716