
from operator import itemgetter

input_file = open("2025/Inputs/2025 Day 03.txt").readlines()

# Clean missing values
def process_input(input):
    return input.replace("\n", "")

# Return the largest digit in a string
def get_max(n_str):
    return str(max(map(int, n_str)))

# Scan a string for the largest digit
# Return the string following that digit, the digit, and the final iteration loop (=0 after recursion)
# `iteration` controls how many times to search the larget remaining digit
def select_max_volt(i_atomic, volt_list = "", iteration = 2):
    if iteration == 0:
        return i_atomic, int(volt_list), iteration
    else:
        if iteration == 1:
            i_atomic_in_range = i_atomic
        else:
            i_atomic_in_range = i_atomic[:-(iteration - 1)]
        max_volt = get_max(i_atomic_in_range)
        max_vold_index = i_atomic_in_range.index(max_volt)
        return select_max_volt(i_atomic[(max_vold_index + 1):], volt_list + max_volt, iteration - 1)

# Part 1
sum(map(itemgetter(1), map(select_max_volt, map(process_input, input_file)))) # 17430

# Part 2
def select_12_max_volts(i_atomic, volt_list = ""):
    return select_max_volt(i_atomic, volt_list, iteration = 12)

# Part 2
sum(map(itemgetter(1), map(select_12_max_volts, map(process_input, input_file)))) # 171975854269367
