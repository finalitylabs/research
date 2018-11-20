#!/usr/bin/python3

import struct
import io
import hashlib

with io.open('primes.dat', 'rb') as f:
    primes = f.read()

NUM_PRIMES = 2 ** 20

def get_prime(i):
    p = primes[4*i : 4*i+4]
    return struct.unpack('>L', p)[0]

def hasher(data):
    index = hashlib.sha256(data).digest()
    index = int.from_bytes(index, byteorder='big')
    index = index % NUM_PRIMES
    return(get_prime(index))

print(hasher(b'A Transaction'))
