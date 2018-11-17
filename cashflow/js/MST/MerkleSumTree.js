const utils = require('web3-utils');
const Int64BE = require("int64-buffer").Int64BE;

const encode = (data) => {
  const encoded = Int64BE(data)
  return encoded
}

const decode = (data) => {
  const decoded = data.toNumber()
  return decoded
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
    this.checkConsecutive(leaves);

    this.buckets = leaves.map(leaf => leaf.getBucket())
    let buckets = this.buckets
    while (buckets.length !== 1) {
      const newBuckets = [];
      while (buckets.length > 0) {
        if (buckets.length >= 2) {
          const b1 = buckets.pop(0)
          const b2 = buckets.pop(0)
          const size = b1.size + b2.size
          const hashed = utils.soliditySha3(encode(b1.size) + b1.hashed + encode(b2.size) + b2.hashed)
          const b = new Bucket(size, hashed)
          b1.parent = b2.parent = b
          b1.right = b2
          b2.left = b1
          newBuckets.push(b)
        } else {
          newBuckets.push(buckets.pop(0))
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
      const bucket = right ? right : curr.left
      curr = curr.parent
      proof.push(new ProofStep(bucket, right))
    }
    return proof
  }

  verifyProof(root, leaf, proof) {
    // Validates the supplied `proof` for a specific `leaf` according to the
    // `root` bucket of Merkle-Sum-Tree.
    const sizeArr = proof.map(s => s.bucket.size ? s.bucket.size : s.right)
    const rng = [sum(sizeArr), (root.size - sum(sizeArr))]
    // Supplied steps are not routing us to the range specified.
    if (rng !== leaf.rng) return false
    curr = leaf.getBucket()
    for (step in proof) {
      if (step.right) {
        hashed = utils.soliditySha3(encode(curr.size) + curr.hashed + encode(step.bucket.size) + step.bucket.hashed)
      } else {
        hashed = utils.soliditySha3(encode(step.bucket.size) + step.bucket.hashed + encode(curr.size) + curr.hashed)
      }
      curr = Bucket(curr.size + step.bucket.size, hashed)
    }
    return curr.size == root.size && curr.hashed == root.hashed
  }

  sum(arr) {
    var result = 0, n = arr.length || 0; //may use >>> 0 to ensure length is Uint32
    while(n--) {
      result += +arr[n]; // unary operator to ensure ToNumber conversion
    }
    return result;
  }
}

module.exports= {
  Leaf,
  MerkleSumTree
}