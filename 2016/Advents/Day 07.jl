# Part 1
fork(bin::Function, f::Function, g::Function) = x -> bin(f(x), g(x))

ispalindrome = fork(==, reverse, identity)

map_f = f -> x -> map(f, x)

filter_f = f -> x -> filter(f, x)

split_ip(string::String) = String.(split(string, r"(?:\[|\])"))

function is_abba(string::String)
    n = 4
    index = 0:(length(string) - n)
    slice(string::String) = i -> string[i .+ (1:n)]
    is_repeated(string::String) = string == string[1] ^ length(string)
    (any ∘ map_f(fork(&, !is_repeated, ispalindrome) ∘ slice(string)))(index)
end

odds(v::Vector) = v[1:2:length(v)]

evens(v::Vector) = v[2:2:length(v)]

is_tls = fork(&, all ∘ map_f(!) ∘ evens, any ∘ odds) ∘ map_f(is_abba) ∘ split_ip

count_ip = length ∘ filter_f(is_tls)

ip_address = readlines("Inputs/Day 07.txt")

# The first component is never a hypernet
ip_address .|> first .|> ==('[') |> any

count_ip(ip_address) # 110

# Part 2
function get_abas(string::String)
    if length(string) == 3
        if fork(==, first, last)(string) string end
    else
        n = 3
        index = 0:(length(string) - n)
        slice(string::String) = i -> string[i .+ (1:n)]
        (filter_f(!isnothing) ∘ map_f(get_abas ∘ slice(string)))(index)
    end
end
get_babs = get_abas

flatten = collect ∘ Iterators.Flatten

get_super_abas = flatten ∘ filter_f(!isnothing) ∘ map_f(get_abas) ∘ odds ∘ split_ip
get_hyper_babs = flatten ∘ filter_f(!isnothing) ∘ map_f(get_babs) ∘ evens ∘ split_ip

second = first ∘ evens ∘ collect
bab_to_aba = fork(*, fork(*, second, first), second)

is_ssl(string::String) = (any ∘ map_f(hyper -> hyper ∈ get_super_abas(string)) ∘ map_f(bab_to_aba) ∘ get_hyper_babs)(string)

count_ssl = length ∘ filter_f(is_ssl)

filter_f(is_ssl)(ip_address) # 242
