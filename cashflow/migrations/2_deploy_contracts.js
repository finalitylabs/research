var MerkleSumTree = artifacts.require("./MerkleSumTree.sol")
var MSTImplementation = artifacts.require("./MSTImplementation.sol")

module.exports = function (deployer) {
  deployer.deploy(MerkleSumTree).then(() => {
      deployer.deploy(MSTImplementation);
  });
  deployer.link(MerkleSumTree, MSTImplementation);
};

