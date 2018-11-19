pragma solidity ^0.4.24;

import  "./MerkleSumTree.sol";

contract MSTImplementation {
  function verifyProof(
    bytes proof,
    bytes32 rootHash, uint64 rootSize, // Root bucket
    bytes32 leafHash, uint64 leafStart, uint64 leafEnd // Leaf bucket
  )
    public 
    view 
    returns (bool)
  {
    return MerkleSumTree.verify(proof, rootHash, rootSize, leafHash, leafStart, leafEnd);
  }
}