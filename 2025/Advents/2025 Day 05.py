
input_file = open("2025/Inputs/2025 Day 05.txt").readlines()

def read_range(range_str):
    return list(map(int, range_str.split("-")))

def parse_input(input_file):

    input = [str.replace('\n', "") for str in input_file]

    blank_index = input.index("")

    return list(map(read_range, input[:blank_index])), list(map(int, input[(blank_index+1):]))

def check_ingredient(ingredient, lst_id_range):

    return lst_id_range[0] <= ingredient and ingredient <= lst_id_range[1]

def check_overlap(x_bar, y_bar):
    x_1, x_2 = x_bar
    y_1, y_2 = y_bar
    if y_1 <= x_1 and x_1 <= y_2 and y_2 <= x_2:
        return [y_1, x_2]
    elif y_1 <= x_1 and x_1 <= x_2 and x_2 <= y_2:
        return [y_1, y_2]
    elif x_1 <= y_1 and y_1 <= y_2 and y_2 <= x_2:
        return [x_1, x_2]
    elif x_1 <= y_1 and y_1 <= x_2 and x_2 <= y_2:
        return [x_1, y_2]
    else:
        return None

# Part 1
lst_id_ranges, ingredients = parse_input(input_file)

sum(map(lambda ingredient : any(map(lambda id_range: check_ingredient(ingredient, id_range),
                                    lst_id_ranges)),
        ingredients)) # 726

# Part 2
def flatten_range(lst_id_ranges):

    outer_loop = 0
    inner_loop = 1

    while True:

        max_index = len(lst_id_ranges) - 1

        if outer_loop >= max_index:
            return lst_id_ranges

        x_bar = lst_id_ranges[outer_loop]
        y_bar = lst_id_ranges[inner_loop]

        new_range = check_overlap(x_bar, y_bar)

        if new_range is not None:
            # Must remove inner_loop > outer_loop first
            del lst_id_ranges[inner_loop]
            del lst_id_ranges[outer_loop]
            lst_id_ranges.append(new_range)
            outer_loop = 0
            inner_loop = 1
        else:
            if inner_loop < max_index:
                inner_loop += 1
            else:
                outer_loop += 1
                inner_loop = outer_loop + 1

def count_sequence(seq, inclusive = True):
    if inclusive:
        return seq[1] - seq[0] + 1
    else:
        return seq[1] - seq[0]

sum(map(count_sequence, flatten_range(lst_id_ranges.copy()))) # 354226555270043

