def infinite_arguments(*args):
    sum = 0
    for arg in range(100000000000):
        sum += arg
    return sum


print(infinite_arguments())