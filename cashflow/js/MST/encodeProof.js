
const bytesFromHex = (str,pad) =>{
  str = str.toString()
  if (str.length%2) str="0"+str;
  var bytes = str.match(/../g).map(function(s){
      console.log(s)
      return parseInt(s,16);
  });
  if (pad) for (var i=bytes.length;i<pad;++i) bytes.unshift(0);
  return bytes.toString().replace(/,/g, '');
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
    const sizeArr = bytesFromHex(d.bucket.size, 16)
    proofBytes += sizeArr
    proofBytes += d.bucket.hashed.substring(2)
  })                         

  "0x000000000000000005efbde2c3aee204a69b7696d4b10ff31137fe78e3946306284f806e2dfc68b8050000000000000000016dc1f2cbadf3cf42e13fed7a5bc239fe828329bb0dd8ef456bed7ab94dec6c598010000000000000011289d7cdd4e64c94f59c5d4c7db419624f7f097c889a5cbdc59980a7fb83733fac7"
  "0x000000000000000005efbde2c3aee204a69b7696d4b10ff31137fe78e3946306284f806e2dfc68b80500000000000000000adc1f2cbadf3cf42e13fed7a5bc239fe828329bb0dd8ef456bed7ab94dec6c5980100000000000000b49d7cdd4e64c94f59c5d4c7db419624f7f097c889a5cbdc59980a7fb83733fac7"
  return proofBytes
}

module.exports = encodeProof