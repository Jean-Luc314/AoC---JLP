struct Command
    f :: String
    arg :: Union{String, Nothing}
    function Command(line::String)
        if line[1] != '$'
            error("Commands begin with \$")
        end
        f = match(r"(?<=\$ )[a-z]+(?=)", line).match
        if f ∉ ["cd", "ls"]
            error("Command must be 'cd' or 'ls'")
        end
        function get_arg(line, f)
            arg = match(Regex("(?<=\\\$ $f ).+"), line)
            if arg === nothing
                arg
            else
                arg.match
            end
        end
        arg = get_arg(line, f)
        new(f, arg)
    end
end
struct File
    name :: String
    size :: Int
    function File(line::String)
        size = parse(Int, match(r"[0-9]+(?= )", line).match)
        name = match(Regex("(?<=$size ).+"), line).match
        new(name, size)
    end
end
struct Folder
    name :: String
    files :: Vector{File}
    folders :: Union{Vector{Folder}, Nothing}
end
struct Directory
    dir :: String
    function Directory(cmd::Command)
        
    end
end
struct Terminal
    T_type
    function Terminal(line::String)
        x = first(split(line, " "))
        if x == "\$"
            Command
        elseif x == "dir"
            Directory
        else
            File
        end
    end
end
function sum(files::Vector{File})::Int
    Σ(x::Int, y::File) = x + y.size
    reduce(Σ, files, init = 0)
end
function sum(folder::Folder)::Int
    sum(folder.files) + sum.(folder.folders)
end

input = readlines("2022/Inputs/Day 07.txt")

Command(input[end - 3])

line = input[4]
[File(line), File(line)] |> sum

line = input[1]

Terminal(line)(line)

function Filesystem(dir::String)
    cmd = Command(dir)
    Filesystem([cmd.arg], Dict())
end

# Reattempt

abstract type Item end
struct Dir <: Item
    line :: String
end
struct File <: Item
    line :: String
end

struct Filesystem
    dir :: Vector{String}
    sub_dir_count :: Int
    tree :: Dict{String, Vector{File}}
end
function Filesystem()
    Filesystem(Vector{String}(), 0, Dict{String, Vector{File}}())
end

system = Filesystem()

input = readlines("2022/Inputs/Day 07.txt")
# Loop through instructions in order
# Detect if the instruction is a command, a directory, or a file
# If a command, either cd or ls
    # If cd, then update system.dir
    # If ls, move on
# Otherwise, either a dir or a file
i = 1
while i <= length(input)
    line = input[i]
    if line[1] == '$'
        cmd = Command(line)
        if cmd.f == "cd"
            system.dir = cmd.arg
        end
    elseif line[1] == "d"

    end
    i += 1
end


# Think about solving this problem as a generator, using readline
# Read first line, it's cd so set directory
# Read next line, it's ls, so need to keep reading until the next line is a command
# Then need to create the files / folders at this directory