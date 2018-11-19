const tryCatch = require("./exceptions.js").tryCatch;
const errTypes = require("./exceptions.js").errTypes;
const MerkleSumTreeJs = require('./../js/MST/MerkleSumTree').MerkleSumTree
const Leaf = require('./../js/MST/MerkleSumTree').Leaf
const encodeProof = require('./../js/MST/encodeProof')

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
// - Assert equal for two values:
//   assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, "Library function returned unexpected function, linkage may be broken");

contract('Tests for the Merklesumtree implementation', (accounts) => {
  const treeJs = new MerkleSumTreeJs(leaves);
  const proof = treeJs.getProof(3)
  const leaf = leaves[3]
  const root = treeJs.getRoot()

  it('should be valid when providing the right proof', () => {
    treeJs.verifyProof(root, leaves[3], proof)
  })

  it('should be able to verify the proof provided by the JS merkle tree after encoding it', async () => {
    const TreeSol = await MerkleSumTreeSol.deployed()
    const encodedProof = encodeProof(proof)
    const verified = await TreeSol.verify(
      encodedProof, 
      root.hashed, root.size,
      leaf.getBucket().hashed, leaf.rng[0], leaf.rng[1]
    )
    assert.equal(verified, true, "Wrong proof");
  })
});
