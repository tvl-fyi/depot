import random

# This class of problems is known as "resevoir sampling".
def choose_a(m, xs):
    """
    Randomly choose `m` elements from `xs`.
    This algorithm runs in linear time with respect to the size of `xs`.
    """
    result = [None] * m
    for i in range(len(xs)):
        j = random.randint(0, i)
        if j < m:
            result[j] = xs[i]
    return result

def choose_b(m, xs):
    """
    This algorithm, which copies `xs`, which runs in linear time, and then
    shuffles the copies, which also runs in linear time, achieves the same
    result as `choose_a` and both run in linear time.

    `choose_a` is still preferable since it has a coefficient of one, while this
    version has a coefficient of two because it copies + shuffles.
    """
    ys = xs[:]
    random.shuffle(ys)
    return ys[:m]

def choose_c(m, xs):
    """
    This is one, possibly inefficient, way to randomly sample `m` elements from
    `xs`.
    """
    choices = set()
    while len(choices) < m:
        choices.add(random.randint(0, len(xs) - 1))
    return [xs[i] for i in choices]

# ROYGBIV
xs = [
    'red',
    'orange',
    'yellow',
    'green',
    'blue',
    'indigo',
    'violet',
]
print(choose_b(3, xs))
print(choose_c(3, xs))
