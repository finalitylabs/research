const tryCatch = require("./exceptions.js").tryCatch;
const errTypes = require("./exceptions.js").errTypes;

const HashToPrimeSol = artifacts.require("HashToPrime.sol")
const BigNumber = artifacts.require("BigNumber.sol")
const RLPReader = artifacts.require("RLPReader.sol")
const ParentSol = artifacts.require("Parent.sol")

const Web3latest = require('web3-utils')
const RLP = require('rlp')
//const web3latest = new Web3latest(new Web3latest.providers.HttpProvider("http://localhost:8545")) //ganache port

// - Expecting errors (reverts):
//   await tryCatch(personalToken.mintPersonalToken(account1, tokenUri1, {from: accounts[1], value: fee}), errTypes.revert);
// - Async assert equal: 
//   expect(await asyncFunction.to.equal(symbol);
// - Assert equal for two values:
//   assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, "Library function returned unexpected function, linkage may be broken");

let htp
let g = '0x03'
let N = '0xC7970CEEDCC3B0754490201A7AA613CD73911081C790F5F1A8726F463550BB5B7FF0DB8E1EA1189EC72F93D1650011BD721AEEACC2ACDE32A04107F0648C2813A31F5B0B7765FF8B44B4B6FFC93384B646EB09C7CF5E8592D40EA33C80039F35B4F14A04B51F7BFD781BE4D1673164BA8EB991C2C4D730BBBE35F592BDEF524AF7E8DAEFD26C66FC02C479AF89D64D373F442709439DE66CEB955F3EA37D5159F6135809F85334B5CB1813ADDC80CD05609F10AC6A95AD65872C909525BDAD32BC729592642920F24C61DC5B3C3B7923E56B16A4D9D373D8721F24A3FC0F1B3131F55615172866BCCC30F95054C824E733A5EB6817F7BC16399D48C6361CC7E5'

contract('', function(accounts) {

  before(async () => {
    //htp = await HashToPrimeSol.new()
    chain = await ParentSol.new(g, N)
  })

  it('calls hash to prime', async () => {
    // let res = await htp.hash('0x03')
    // let gasUsed = res.receipt.gasUsed
    // console.log(gasUsed)

    // let test2 = await htp.test2()
    // console.log(test2.toString())

    // for(var i=0; i<100; i++) {
    //   let test = await htp.test(i)
    //   console.log(test.toString())

    //   // let test2 = await htp.test3(i)
    //   // console.log(test2.toString())
    // }

    // address owner,
    // uint32 numRanges,
    // uint256 timeStart,
    // uint[] memory starts,
    // uint[] memory offsets//,

    //let list = [accounts[0], 1, 0, [1], [1]]
    let exitParams = [accounts[0], 1, 1, 1, 1]
    let encoded = RLP.encode(exitParams)
    console.log(encoded)
    let decoded = RLP.decode(encoded)
    console.log(decoded)

    let res = await chain.deposit({value:Web3latest.toWei('1')})
    let amt = await chain._amt()
    console.log(amt.toString())

    res = await chain.challengeInvalidExitHTP('0x04')
    let gasUsed = res.receipt.gasUsed
    console.log(gasUsed)

    let p = await chain.p()
    console.log(p.toString())

    await chain.startExit(encoded)
    let numExits = await chain.numExits()
    console.log(numExits.toString())

    let exit = await chain.getExit(numExits.toString())
    console.log(exit)

    let bal = await web3.eth.getBalance(accounts[0])
    console.log(bal)

    await chain.finalizeExit(numExits.toString())
    bal = await web3.eth.getBalance(accounts[0])
    console.log(bal)
  })

  it('', async () => {
    //assert.equal(verified, true, "Wrong proof");
  })
});
