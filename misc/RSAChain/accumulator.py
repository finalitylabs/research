#!/usr/bin/python3

def mult(primes):
    ret = 1
    for p in primes:
        ret *= p
    return ret

def hasher(data):
    import hashlib
    return int.from_bytes(hashlib.sha256(str(data).encode('ascii')).digest(), byteorder='big')

class AccumulatorChain:
    def __init__(self, g, n):
        self.n = n
        self.blocks = [(),]
        self.accums = [g,]

    def new_block(self, primes):
        acc = pow(self.accums[-1], mult(primes), self.n)
        self.blocks.append(primes)
        self.accums.append(acc)
        print(self.blocks,self.accums)

    def get_inclusion_proof(self, block, prime):
        primes = set(self.blocks[block])
        g = self.accums[block - 1]
        A = self.accums[block]
        if prime not in primes:
            raise Exception("Prime {} does not exist in block {}!".format(prime,block))
        primes.remove(prime)
        x = mult(primes)
        h = g ** prime
        B = hasher(g * A)
        b = pow(h, x // B, self.n)
        r = x % B
        return (b, r)

    def get_exclusion_proofs(self, block, count, prime):
        blocks = self.blocks[block:block+count]
        g = self.accums[block - 1]
        A = self.accums[block + count - 1]
        for b in blocks:
            if prime in b:
                raise Exception("Prime {} does exist in block {}!".format(prime,block))
        Q = mult([mult(b) for b in blocks])
        s = Q % prime
        x = (Q - s) // prime
        h = g ** prime
        B = hasher(g * A)
        b = pow(h, x // B, self.n)
        r = x % B
        return (b, r, s)

    def verify_inclusion_proof(g, A, n, prime, proof):
        b, r = proof
        h = g ** prime
        B = hasher(g * A)
        return (pow(b, B, n) * pow(h, r, n)) % n == A

    def verify_exclusion_proof(g, A, n, prime, proof):
        b, r, s = proof
        if s >= prime or s <= 0:
            return False
        h = g ** prime
        B = hasher(g * A)
        return (pow(b, B, n) * pow(h, r, n) * pow(g, s, n)) % n == A

if __name__ == "__main__":
    G = 3
    N = 167 * 173
    chain = AccumulatorChain(G, N)
    chain.new_block({3,5,11}) # Block 1
    chain.new_block({13,17,19}) # Block 2
    chain.new_block({23,29,31}) # Block 3

    proof = chain.get_inclusion_proof(1, 11)
    print(AccumulatorChain.verify_inclusion_proof(chain.accums[0],chain.accums[1],chain.n,11,proof))
    proof = chain.get_inclusion_proof(2, 13)
    print(AccumulatorChain.verify_inclusion_proof(chain.accums[1],chain.accums[2],chain.n,13,proof))
    proof = chain.get_inclusion_proof(3, 31)
    print(AccumulatorChain.verify_inclusion_proof(chain.accums[2],chain.accums[3],chain.n,31,proof))

    proof = chain.get_exclusion_proofs(1, 2, 7) # Exclusion proof for block 1 & 2
    print(AccumulatorChain.verify_exclusion_proof(chain.accums[0],chain.accums[2],chain.n,7,proof))
    proof = chain.get_exclusion_proofs(2, 2, 7) # Exclusion proof for block 2 & 3
    print(AccumulatorChain.verify_exclusion_proof(chain.accums[1],chain.accums[3],chain.n,7,proof))
    proof = chain.get_exclusion_proofs(1, 3, 7) # Exclusion proof for block 1 & 2 & 3
    print(AccumulatorChain.verify_exclusion_proof(chain.accums[0],chain.accums[3],chain.n,7,proof))
