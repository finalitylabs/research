const Leaf = require('./MerkleSumTree').Leaf
const MerkleSumTree = require('./MerkleSumTree').MerkleSumTree

TREE_SIZE = 2 ** 64

const leaves = [ new Leaf([0, 4], null), // None means the leaf is empty.
    new Leaf([4, 10], "tx1"),
    new Leaf([10, 15], null),
    new Leaf([15, 20], "tx2"),
    new Leaf([20, 90], "tx4"),
    new Leaf([90, TREE_SIZE], null)]
    
const tree = new MerkleSumTree(leaves)
console.log('tree', tree)
// const root = tree.getRoot()
// const proof = tree.getProof(3)

// if (tree.verifyProof(root, leaves[3], proof)) {
//     console.log("Proof is valid!")
// } else {
//     console.log("Proof is not valid!")
// }