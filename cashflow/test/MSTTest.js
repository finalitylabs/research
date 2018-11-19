const tryCatch = require("./exceptions.js").tryCatch;
const errTypes = require("./exceptions.js").errTypes;
const MerkleSumTreeJs = require('./../js/MST/MerkleSumTree').MerkleSumTree
const Leaf = require('./../js/MST/MerkleSumTree').Leaf
// const encodeProof = require('./../js/MST/encodeProof')

const MerkleSumTreeSol = artifacts.require("MerkleSumTree")

const leaves = [ 
  new Leaf([0, 4], null), // None means the leaf is empty.
  new Leaf([4, 10], "tx1"),
  new Leaf([10, 15], null),
  new Leaf([15, 20], "tx2"),
  new Leaf([20, 90], "tx4"),
  new Leaf([90, 200], null)
]

// - Expecting errors (reverts):
//   await tryCatch(personalToken.mintPersonalToken(account1, tokenUri1, {from: accounts[1], value: fee}), errTypes.revert);
// - Async assert equal: 
//   expect(await asyncFunction.to.equal(symbol);

contract('Tests for the Merklesumtree implementation', (accounts) => {
  const account = accounts[0]
  const treeJs = new MerkleSumTreeJs(leaves);
  const proof = treeJs.getProof(3)
  const leaf = leaves[3]
  const root = treeJs.getRoot()

  it('should be valid when providing the right proof', () => {
    treeJs.verifyProof(root, leaves[3], proof)
  })

  it('should be able to verify the proof provided by the JS merkle tree after encoding it', async () => {
    console.log(proof)
    // const TreeSol = await MerkleSumTreeSol.new()
    // const encodedProof = encodeProof(proof)
    // const verified = await TreeSol.verifyProof(
    //   encodedProof, 
    //   root.hashed, 
    //   root.size,leaf.hashed, 
    //   leaf.rng[0], 
    //   leaf.rng[1]
    // )
    // expect(verified.to.equal(true))
    // console.log(verified)
  })
});
