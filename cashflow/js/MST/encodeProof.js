const utils = require('web3-utils')

const encodeProof = (proof) => {
  const hashedProof = ""
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
    hashedProof += hashed
  })
  console.log(hashedProof)
}

module.exports = encodeProof