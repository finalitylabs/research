const tryCatch = require("./exceptions.js").tryCatch;
const errTypes = require("./exceptions.js").errTypes;

const HashToPrimeSol = artifacts.require("HashToPrime.sol")

// - Expecting errors (reverts):
//   await tryCatch(personalToken.mintPersonalToken(account1, tokenUri1, {from: accounts[1], value: fee}), errTypes.revert);
// - Async assert equal: 
//   expect(await asyncFunction.to.equal(symbol);
// - Assert equal for two values:
//   assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, "Library function returned unexpected function, linkage may be broken");

let htp

contract('', function(accounts) {

  before(async () => {
    htp = await HashToPrimeSol.new();
  })

  it('calls hash to prime', async () => {
    let res = await htp.hash('0xb7afe31CF6b3')
    let gasUsed = res.receipt.gasUsed
    console.log(gasUsed)

    let test2 = await htp.test2()
    console.log(test2.toString())

    // for(var i=0; i<100; i++) {
    //   let test = await htp.test(i)
    //   console.log(test.toString())

    //   // let test2 = await htp.test3(i)
    //   // console.log(test2.toString())
    // }
  })

  it('', async () => {
    //assert.equal(verified, true, "Wrong proof");
  })
});
