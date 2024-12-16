using HTTP, Gumbo, AbstractTrees

r = HTTP.get("https://adventofcode.com/2023/day/9")

println(String(r.body))

r