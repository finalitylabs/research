const Leaf = require('./MerkleSumTree').Leaf
const MerkleSumTree = require('./MerkleSumTree').MerkleSumTree
const encodeProof = require('./encodeProof')

const TREE_SIZE = 200 // TODO: make this 2 ** 64 and implement BN.js in MerkleSumTree.js

const leaves = [ 
    new Leaf([0, 4], null), // None means the leaf is empty.
    new Leaf([4, 10], "tx1"),
    new Leaf([10, 15], null),
    new Leaf([15, 20], "tx2"),
    new Leaf([20, 90], "tx4"),
    new Leaf([90, TREE_SIZE], null)
]
    
const tree = new MerkleSumTree(leaves)
// const root = tree.getRoot()
const proof = tree.getProof(3)
const encodedProof = encodeProof(proof)
// if (tree.verifyProof(root, leaves[3], proof)) {
//     console.log("Proof is valid!")
// } else {
//     console.log("Proof is not valid!")
// }