#!/usr/bin/python3

def is_prime(n):
    for i in range(2, n):
        if n % i == 0:
            return False
    return True
primes = [i for i in range(2, 10000) if is_prime(i)][:1024]

def get_prime(forest, level, offset):
    s = 2 ** (forest + 1) - 1 - forest - 1
    s += 2 ** level - 1
    s += offset
    return s

for f in range(5):
    for l in range(f + 1):
        for o in range(2 ** l):
            print(get_prime(f,l,o), end=" ")
        print()
    print()
    print()
input("Press any key...")
def jump(depth, index):
    if index >= 2 ** depth:
        raise "Bad index!"
    if depth == 0:
        return 1
    else:
        sub = 2 ** (depth - 1)
        res = jump(depth - 1, index % sub)
        if index == 0:
            res *= 2
        return res

def slices(depth, start, end):
    res = []
    curr = start
    while curr <= end:
        ln = jump(depth, curr)
        while curr + ln - 1 > end:
            ln = ln // 2
        res.append((curr,curr + ln - 1))
        curr += ln
    return res

D = 40

def get_branch(level, offset):
    forest = level
    tmp = offset
    inc = []
    exc = []
    while level >= 0:
        inc.append(get_prime(forest, level, offset))
        level -= 1
        offset //= 2
    for i in range(D + 1):
        if i != forest:
            f = forest
            t = tmp
            while f > i:
                f -= 1
                t //= 2
            exc.append(get_prime(i,f,t))
    return (inc, exc)

import math

ss = slices(D,0,2**40-2)
inc = []
exc = []
for i,j in ss:
    ln = int(math.log2(j-i+1))
    level = D - ln
    offset = i // 2 ** ln
    i,e = get_branch(level, offset)
    print(len(i))
    inc.extend(i)
    exc.extend(e)
print(len(inc),len(exc))
