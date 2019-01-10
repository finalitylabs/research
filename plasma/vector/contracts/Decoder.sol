pragma solidity ^0.5.0;

import { RLPReader } from "./RLPReader.sol";
import {HashToPrime} from "./math/HashToPrime.sol";

library Decoder {
  using RLPReader for RLPReader.RLPItem;
  using RLPReader for bytes;

  struct ExpProof {
    bytes T; // coin proof g^w, block proof g^w = A_t/x = A_t-1 where x is all new primes in A_t
    bytes r; // r = w mod B
    bytes k; // k = floor(w/B)
    bytes B; // htp(g, T)
  }

  struct Block {
    bytes accumulator;
    ExpProof blockProof;
  }

  struct Exit {
    address owner;
    uint32 numRanges;
    uint256 timeStart;
    uint32[] offsets;
    ExpProof coinsProof;
    uint8 challenge; // 1 means this exit is flagged for challenge
  }

  struct TX {
    bytes32 r;
    bytes32 s;
    uint8 v;
    // todo, less important, any format should work
    // inluding experiements with hashed scripts and challenges
  }

  function decodeBlock(bytes memory rlpBytes) internal returns(Block memory) {
    return _decodeBlock(rlpBytes.toRlpItem().toList());
  }

  function _decodeBlock(RLPReader.RLPItem[] memory items) private returns(Block memory) {
    return Block({
      accumulator: items[0].toBytes(),
      blockProof: _decodeProof(items[1].toList())
    });
  }

  function decodeExit(bytes memory rlpBytes) internal returns(Exit memory) {
    return _decodeExit(rlpBytes.toRlpItem().toList());
  }

  function _decodeExit(RLPReader.RLPItem[] memory items) private returns(Exit memory) {
    return Exit({
      owner: msg.sender,
      numRanges: uint32(items[0].toUint()),
      timeStart: uint256(items[1].toUint()),
      offsets: _decodeOffsets(items[2].toList()),
      coinsProof: ExpProof('0x','0x','0x','0x'),
      challenge: 0
    });
  }

  function _decodeOffsets(RLPReader.RLPItem[] memory items) private returns(uint32[] memory) {
    uint32[] memory arr;
    for(uint i=0; i<items.length; i++){
      arr[i] = uint32(items[i].toUint());
    }
    return arr;
  }

  function decodeProof(bytes memory rlpBytes) internal returns(ExpProof memory) {
    return _decodeProof(rlpBytes.toRlpItem().toList());
  }

  function _decodeProof(RLPReader.RLPItem[] memory items) private returns(ExpProof memory) {
    return ExpProof({
      T: items[0].toBytes(),
      r: items[1].toBytes(),
      k: items[2].toBytes(),
      B: items[3].toBytes()
    });
  }

}
