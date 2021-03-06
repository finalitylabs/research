const utils = require('web3-utils')
const Int64BE = require("int64-buffer").Int64BE
const BN = require('bignumber.js')

const encode = (data) => {
  const encoded = Int64BE(data)
  return encoded
}

const sum = (arr) => {
  let result = 0
  arr.forEach(d => {result += d})
  return result;
}

class Bucket {
  constructor(size, hashedData) {
    this.size = size
    this.hashed = hashedData
    // Each node in the tree can have a parent, and a left or right neighbor.
    this.parent = null
    this.left = null
    this.right = null
  }
}

class Leaf{
  constructor(rng, data) {
    this.rng = rng
    this.data = data
  }

  getBucket() {
    const hashedData = this.data ? utils.soliditySha3(this.data) : utils.soliditySha3('null')
    return new Bucket(this.rng[1] - this.rng[0], hashedData)
  }
}

class ProofStep {
  constructor(bucket, right) {
    this.bucket = bucket
    this.right = right // Whether the bucket hash should be appended on the right side in this step (Default is left)
  }
}

class MerkleSumTree {
  constructor(leaves) {
    this.checkConsecutive(leaves)

    this.buckets = leaves.map(leaf => leaf.getBucket())
    var buckets = this.buckets.slice()
    while (buckets.length != 1) {
      const newBuckets = []
      while (buckets.length > 0) {
        if (buckets.length >= 2) {
          const b1 = buckets.shift()
          const b2 = buckets.shift()
          const size = b1.size + b2.size
          const hashed = utils.soliditySha3(
            {type: "uint64", value: b1.size},
            {type: "bytes32", value: b1.hashed},
            {type: "uint64", value: b2.size},
            {type: "bytes32", value: b2.hashed});
          const b = new Bucket(size, hashed)
          b1.parent = b2.parent = b
          b1.right = b2
          b2.left = b1
          newBuckets.push(b)
        } else {
          newBuckets.push(buckets.pop())
        }
      }
      buckets = newBuckets
    }
    this.root = buckets[0]
  }

  checkConsecutive(leaves) {
    let curr = 0
    leaves.forEach(leaf => {
      if (leaf.rng[0] != curr) throw new Error("Leaf ranges are invalid!")
      curr = leaf.rng[1]
    })
  }

  getRoot() {
    return this.root
  }

  getProof(index) {
    var curr = this.buckets[index]
    const proof = []
    while (curr.parent) {
      const right = curr.right ? true : false
      const bucket = curr.right ? curr.right : curr.left
      curr = curr.parent
      proof.push(new ProofStep(bucket, right))
    }
    return proof
  }

  verifyProof(root, leaf, proof) {

    // Validates the supplied `proof` for a specific `leaf` according to the
    // `root` bucket of Merkle-Sum-Tree.
    const leftProofStepArr = proof.map(s => !s.right ? s.bucket.size : 0)
    const rightProofStepArr = proof.map(s => s.right ? s.bucket.size : 0)
    const rng = [sum(leftProofStepArr), (root.size - sum(rightProofStepArr))]

    // Supplied steps are not routing us to the range specified.
    if (rng[0] !== leaf.rng[0] || rng[1] !== leaf.rng[1]) return false // TODO: this needs to be an arr comparison, right now the range arrays are never equal
    let curr = leaf.getBucket()

    var hashed;
    proof.forEach(step => {
      if (step.right) {
        hashed = utils.soliditySha3(
                  {type: "uint64", value: curr.size},
                  {type: "bytes32", value: curr.hashed},
                  {type: "uint64", value: step.bucket.size},
                  {type: "bytes32", value: step.bucket.hashed});
      } else {
        hashed = utils.soliditySha3(
                  {type: "uint64", value: step.bucket.size},
                  {type: "bytes32", value: step.bucket.hashed},
                  {type: "uint64", value: curr.size},
                  {type: "bytes32", value: curr.hashed});
      }
      curr = new Bucket(curr.size + step.bucket.size, hashed)
    })

    return curr.size == root.size && curr.hashed == root.hashed
  }
}

module.exports= {
  Leaf,
  MerkleSumTree
}
