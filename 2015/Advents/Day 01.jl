# Part 1
## Count the "("
instructions = read("2015/Input/Day 01.txt", String)

total = length(instructions)
up = sum(string(x) == "(" for x in instructions)
down = total - up

floor = up - down
print(floor)

# Part 2