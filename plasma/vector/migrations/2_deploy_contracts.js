var RLPReader = artifacts.require("./RLPReader.sol")
var BigNumber = artifacts.require("./BigNumber.sol")
var Decoder = artifacts.require("./Decoder.sol")
var SafeMath = artifacts.require("./SafeMath")
var HashToPrime = artifacts.require("./HashToPrime.sol")
var Parent = artifacts.require("./Parent.sol")

// module.exports = function (deployer) {
// 	deployer.deploy(RLPReader).then(() => {
// 	   deployer.deploy(BigNumber).then(() => {
// 	   	deployer.deploy(Decoder).then(() => {
// 	   		deployer.deploy(SafeMath).then(() => {
// 	   			deployer.link(RLPReader, HashToPrime)
// 					deployer.link(BigNumber, HashToPrime)
// 	    		deployer.deploy(HashToPrime).then(() => {
// 	    			deployer.link(SafeMath, Parent)
// 	    			deployer.link(Decoder, Parent)
// 	    			deployer.link(HashToPrime, Parent)
// 				    return deployer.deploy(Parent)//.then(() => {
// 							 // deployer.link(RLPReader, Parent)
// 							 // deployer.link(BigNumber, Parent)
// 							 //deployer.link(HashToPrime, Parent)
// 				    //})
// 		  		})
// 		  	})
// 	    })
// 	  })
// 	})
// }

module.exports = async function (deployer) {
	await deployer.deploy(RLPReader)
	await deployer.deploy(BigNumber)
	await deployer.link(RLPReader, HashToPrime)
	await deployer.link(BigNumber, HashToPrime)
  await deployer.deploy(HashToPrime)
  await deployer.link(HashToPrime, Parent)
}

