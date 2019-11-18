# 因为generator是iterator，所以可以对generator调用next获取yield返回的值。

# Iterators also allow us to represent infinite sequences, such as the sequence of natural numbers (1, 2, ...).
class Naturals:
    """
    >>> m = Naturals()
    >>> [next(m) for _ in range(5)]
    [1, 2, 3, 4, 5]
    """
    def __init__(self):
        self.current = 0

    def __iter__(self):
        return self

    def __next__(self):
        self.current += 1
        return self.current
        
def scale(s, k):
    """Yield elements of the iterable s scaled by a number k.

    >>> s = scale([1, 5, 2], 5)
    >>> type(s)
    <class 'generator'>
    >>> list(s)
    [5, 25, 10]

    >>> m = scale(naturals(), 2)
    >>> [next(m) for _ in range(5)]
    [2, 4, 6, 8, 10]
    """
    for elem in s:
        yield elem * k

# Alternate solution
def scale(s, k):
    yield from map(lambda x: x*k, s)