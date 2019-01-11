var HashToPrime = artifacts.require("./HashToPrime.sol")
var RLPReader = artifacts.require("./RLPReader.sol")
var BigNumber = artifacts.require("./BigNumber.sol")

module.exports = function (deployer) {
	deployer.deploy(RLPReader).then(() => {
	   deployer.deploy(BigNumber).then(() => {
	    deployer.deploy(HashToPrime).then(() => {
				deployer.link(RLPReader, HashToPrime)
				deployer.link(BigNumber, HashToPrime)
	    })
	  });
	})
};

