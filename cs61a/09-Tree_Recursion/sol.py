def mario_number(level):
    def ways(n):
        if n < 0:
            return 0
        if n == 0:
            return 1
        if level[n] == 'P':
            return 0
        return ways(n-1) + ways(n-2)
    return ways(len(level)-1)

print(mario_number('-P-P-'))
print(mario_number('-P-P--'))
print(mario_number('--P-P-'))
print(mario_number('---P-P-'))
print(mario_number('-P-PP-'))
print(mario_number('----'))
print(mario_number('----P----'))
print(mario_number('---P----P-P---P--P-P----P-----P-'))


def merge(s1, s2):
    if (len(s1) == 0):
        return s2
    if (len(s2) == 0):
        return s1
    if (s1[0] < s2[0]):
        return [s1[0]] + merge(s1[1:], s2);
    else:
        return [s2[0]] + merge(s1, s2[1:]);

print(merge([1, 3], [2, 4]))
print(merge([1, 2], []))
