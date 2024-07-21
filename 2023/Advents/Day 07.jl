
# Plan
## Functions that convert a cardhand to a Hand, untouched if the input is a Hand
### cardhand |> is_five_of_a_kind |> is_four_of_a_kind |> ...
## If two cardhands are the same, then need a function to rank them.
### rank_cardhand(player_1, player_2)
## Total winnings is rank * bid

parse_number(string) = parse(Int64, string)

match_bid(camal_card) = match(r"(?<=\s)\d+", camal_card).match

match_hand(camal_card) = match(r"[AKQJT2-9]+(?=\s)", camal_card).match

function get_bid(camal_card)
    camal_card |> match_bid |> parse_number
end

function get_cardhand(camal_card)
    camal_card |> match_hand |> String
end

# Function factory, return a function that counts how many specific cards are in a hand. E.g.,
# Julia> counter = create_counter("AA9AA")
# Julia> counter('A')
# Julia> 4
function create_counter(cardhand::String)
    function (card::Char)
        sum(card .== collect(cardhand))
    end
end

# Create a abstract types to understand the ordering of hands
abstract type FiveOfaKind end
abstract type FourOfaKind  <: FiveOfaKind end
abstract type FullHouse    <: FourOfaKind end
abstract type ThreeOfaKind <: FullHouse end
abstract type TwoPair      <: ThreeOfaKind end
abstract type OnePair      <: TwoPair end
abstract type HighCard     <: OnePair end

struct Hand
    cards::String
    type::DataType
end

# Check if the hand is a Five of a Kind
function is_five_of_a_kind(cards::String)
    first_card = first(cards)
    if cards |> collect .|> ==(first_card) |> all
        Hand(cards, FiveOfaKind)
    else
        cards
    end
end

function is_five_of_a_kind(cards::Hand)
    cards
end

# Check if the hand is a Four of a Kind
function is_four_of_a_kind(cards::String)
    card_set = unique(cards)

    count_match = create_counter(cards)

    if card_set .|> count_match .|> ==(4) |> any
        Hand(cards, FourOfaKind)
    else
        cards
    end
end

function is_four_of_a_kind(cards::Hand)
    cards
end

# Check if the hand is a Full House
function is_full_house(cards::String)
    card_set = unique(cards)

    count_match = create_counter(cards)

    three_of_a_kind = card_set .|> count_match .|> ==(3) |> any
    two_of_a_kind   = card_set .|> count_match .|> ==(2) |> any

    if three_of_a_kind & two_of_a_kind
        Hand(cards, FullHouse)
    else
        cards
    end
end

function is_full_house(cards::Hand)
    cards
end

# Check if the hand is a Three of a Kind
function is_three_of_a_kind(cards::String)
    card_set = unique(cards)

    count_match = create_counter(cards)

    three_of_a_kind = card_set .|> count_match .|> ==(3) |> any

    if three_of_a_kind
        Hand(cards, ThreeOfaKind)
    else
        cards
    end
end

function is_three_of_a_kind(cards::Hand)
    cards
end

# Check if the hand is a Two Pair
function is_two_pair(cards::String)
    card_set = unique(cards)

    count_match = create_counter(cards)

    two_pair = card_set .|> count_match .|> ==(2) |> sum |> ==(2)

    if two_pair
        Hand(cards, TwoPair)
    else
        cards
    end
end

function is_two_pair(cards::Hand)
    cards
end

# Check if the hand is a One Pair
function is_one_pair(cards::String)
    card_set = unique(cards)

    count_match = create_counter(cards)

    two_pair = card_set .|> count_match .|> ==(2) |> sum |> ==(1)

    if two_pair
        Hand(cards, OnePair)
    else
        cards
    end
end

function is_one_pair(cards::Hand)
    cards
end

function is_high_card(cards::String)
    Hand(cards, HighCard)
end

function is_high_card(cards::Hand)
    cards
end

function rank_cards(cards_1::String, cards_2::String)
    card_ranks = Dict("23456789TJQKA" |> collect .=> 2:14)
    lookup(card::Char) = card_ranks[card]
    cards_1_ranks = cards_1 |> collect .|> lookup
    cards_2_ranks = cards_2 |> collect .|> lookup

    if first(cards_1_ranks) == first(cards_2_ranks)
        rank_cards(cards_1[2:end], cards_2[2:end])
    else
        first(cards_1_ranks) < first(cards_2_ranks)
    end
end

function isless(hand_1::Hand, hand_2::Hand)
    if hand_1.type == hand_2.type
        rank_cards(hand_1.cards, hand_2.cards)
    else
        hand_1.type <: hand_2.type
    end
end


camal_cards = readlines("2023/Inputs/Day 07.txt")

bids = camal_cards .|> get_bid
cardhands = camal_cards .|> get_cardhand

# Allocate hands to their Hand type
# Vector{Hand}
hands = cardhands .|> is_five_of_a_kind .|> is_four_of_a_kind .|> is_full_house .|> is_three_of_a_kind .|> is_two_pair .|> is_one_pair .|> is_high_card

ranks = sortperm(hands, lt = isless)

hands[ranks] .|> (x -> x.cards) |> println

sum(bids .* ranks) # 251068107


camal_cards = ["99987 929", "72333 958", "JJ333 400"]

bids = camal_cards .|> get_bid
cardhands = camal_cards .|> get_cardhand

hands = cardhands .|> is_five_of_a_kind .|> is_four_of_a_kind .|> is_full_house .|> is_three_of_a_kind .|> is_two_pair .|> is_one_pair .|> is_high_card
ranks = sortperm(hands, lt = isless)

sum(bids .* ranks) # 251068107

is_two_pair("23432")

