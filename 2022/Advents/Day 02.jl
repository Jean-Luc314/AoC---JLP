# Define moves
struct Rock end
struct Paper end
struct Scissors end
struct Rock_Paper_Scissors
    opponent
    you
end
# Define outcomes
struct Win end
struct Lose end
struct Draw end
# Play Rock Paper Scissors
function get_score(rock_paper_scissors::Rock_Paper_Scissors)::Int
    function play(opponent, you)
        wins = Dict(Rock => Scissors, Scissors => Paper, Paper => Rock)
        if opponent == you
            Draw
        elseif wins[you] == opponent
            Win
        else
            Lose
        end
    end
    round_scores = Dict(Win => 6, Draw => 3, Lose => 0)
    shape_scores = Dict(Rock => 1, Paper => 2, Scissors => 3)
    opponent = rock_paper_scissors.opponent
    you = rock_paper_scissors.you
    outcome = play(opponent, you)
    score = round_scores[outcome] + shape_scores[you]
    score
end
function read_move(str::String)
    move_map = Dict("A" => Rock, "B" => Paper, "C" => Scissors,"X" => Rock, "Y" => Paper, "Z" => Scissors)
    opponent, you = split(str, " ") .|> String
    Rock_Paper_Scissors(move_map[opponent], move_map[you])
end

# Part 1
"2022/Inputs/Day 02.txt" |> readlines .|> read_move .|> get_score |> sum
# Part 2
function read_move_cryptic(str::String)
    move_map = Dict("A" => Rock, "B" => Paper, "C" => Scissors,"X" => Lose, "Y" => Draw, "Z" => Win)
    opponent, you = split(str, " ") .|> String
    oppenent_move = move_map[opponent]
    you_move = move_map[you]
    loses = Dict(Rock => Scissors, Scissors => Paper, Paper => Rock)
    if you_move == Draw
        you_move = oppenent_move
    elseif you_move == Lose
        you_move = loses[oppenent_move]
    else
        key = values(loses)
        val = keys(loses)
        wins = Dict(zip(key, val))
        you_move = wins[oppenent_move]
    end
    Rock_Paper_Scissors(oppenent_move, you_move)
end

"2022/Inputs/Day 02.txt" |> readlines .|> read_move_cryptic .|> get_score |> sum