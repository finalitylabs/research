#!/usr/bin/python3

def mult(primes):
    ret = 1
    for p in primes:
        ret *= p
    return ret

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
        b = set(self.blocks[block])
        if prime not in b:
            raise Exception("Prime {} does not exist in block {}!".format(prime,block))
        b.remove(prime)
        return mult(b)

    def get_exclusion_proofs(self, block, count, prime):
        blocks = self.blocks[block:block+count]
        for b in blocks:
            if prime in b:
                raise Exception("Prime {} does exist in block {}!".format(prime,b))
        m = mult([mult(b) for b in blocks])
        r = prime - m % prime
        cofactor = (m + r) // prime
        return (r, cofactor)

    def verify_inclusion_proof(prev_acc, acc, n, prime, proof):
        result = pow(prev_acc, prime * proof, n)
        return result == acc

    def verify_exclusion_proof(prev_acc, acc, n, prime, r, cofactor):
        if r >= prime or r < 0:
            raise Exception("Invalid r!")
        left = pow(prev_acc, prime * cofactor, n)
        right = pow(prev_acc, r, n) * acc % n
        return left == right

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

    r, cof = chain.get_exclusion_proofs(1, 2, 7) # Exclusion proof for block 1 & 2
    print(AccumulatorChain.verify_exclusion_proof(chain.accums[0],chain.accums[2],chain.n,7,r,cof))
    r, cof = chain.get_exclusion_proofs(2, 2, 7) # Exclusion proof for block 2 & 3
    print(AccumulatorChain.verify_exclusion_proof(chain.accums[1],chain.accums[3],chain.n,7,r,cof))
    r, cof = chain.get_exclusion_proofs(1, 3, 7) # Exclusion proof for block 1 & 2 & 3
    print(AccumulatorChain.verify_exclusion_proof(chain.accums[0],chain.accums[3],chain.n,7,r,cof))