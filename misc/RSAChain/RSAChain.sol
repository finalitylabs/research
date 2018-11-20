pragma solidity ^0.4.24;

import "./NumberTheory.sol";

contract RSAChain {

  using NumberTheory for uint256;

  struct Block {
    uint256 exponent;
    uint256 accumulator;
  }

  address operator;
  uint256 N;

  Block[] public blocks;

  constructor(uint256 _N, uint256 _G) public {
    operator = msg.sender;
    N = _N;
    blocks.push(Block(0, _G));
  }

  function submitBlock(uint256 _index, uint256 _exponent, uint256 _accumulator) public {
    require(_index == blocks.length, "Wrong block height!");
    uint256 acc = blocks[_index - 1].accumulator.modPow(_exponent, N);
    require(_accumulator == acc, "Wrong accumulator!");
    blocks.push(Block(_exponent, _accumulator));
  }

}
