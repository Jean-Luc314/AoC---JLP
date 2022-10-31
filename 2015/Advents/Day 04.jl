# Packages
using Pkg
Pkg.add("MD5")
using MD5
# Functions
function is_not_mineable(hash::String, pad::Int = 5)::Bool
    hash[begin:5] != "0" ^ pad
end
function mine_hash(secret_key::String, pad::Int = 5)::Int
    salt = 1
    while secret_key * string(salt) |> md5 |> bytes2hex |> x -> is_not_mineable(x, pad)
        salt += 1
    end
    salt
end
# Read
secret_key = "ckczppom"
# Part 1
secret_key |> mine_hash
# Part 2
mine_hash(secret_key, 6)