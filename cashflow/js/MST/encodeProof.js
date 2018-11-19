const pad = require("pad-left")

const encode = (data) => {
  return pad(data.toString(16), 16,'0')
}

const encodeProof = (proof) => {
  var proofBytes = '0x'; // 8 byte arr of the amount of proofs
  const left = '00'
  const right = '01'
  
  proof.forEach(d => {
    if (d.right) {
      proofBytes += right
    } else {
      proofBytes += left
    }
    const sizeArr = encode(d.bucket.size)
    proofBytes += sizeArr
    proofBytes += d.bucket.hashed.substring(2)
  })                         

  return proofBytes
}

module.exports = encodeProof