get_input() = readline("2022/Inputs/Day 06.txt")
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
    get_input() |> detect_marker
end
part1() = detect_packet(4)
part1() # 1287
part2() = detect_packet(14)
part2() # 3716