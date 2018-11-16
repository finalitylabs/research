const sparceMerkleTreeJS = require('./lib/SparseMerkleTree')
const leafValues = ["1a","2a","3a","4a","5a","6a","7a","8a","9a","10a"]
const leafs = {};

leafValues.forEach((value, index) => {
  leafs[index.toString()] = value
})

const tree = new sparceMerkleTreeJS(leafValues.length, leafs)
console.log('Tree', tree)
console.log('Merkle proof', tree.createMerkleProof('9'))
