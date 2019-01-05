pragma solidity ^0.4.23;

import { RLPReader } from "./RLPReader.sol";
import {HashToPrime} from "./math/HashToPrime.sol";

library Decoder {
  using RLPReader for RLPReader.RLPItem;
  using RLPReader for bytes;

  struct Proof {
    bytes T; // g^w, for block proof, g = g^w^x = A_t-1 where x is all new primes in A_t
    bytes r; // r = w mod B
    bytes k; // k = floor(w/B)
    bytes B; // htp(g, T)
  }

  struct Block {
    bytes accumulator;
    Proof blockProof;
  }

  struct Exit {
    address owner;
    uint32 numRanges;
    uint256 timeStart;
    uint32[] offsets;
    Proof coinsProof;
    uint8 challenge; // 1 means this exit is flagged for challenge
  }

  function decodeBlock(bytes memory rlpBytes) internal returns(Block) {
    return _decodeBlock(rlpBytes.toRlpItem().toList());
  }

  function _decodeBlock(RLPReader.RLPItem[] items) private returns(Block) {
    return Block({
      accumulator: items[0].toBytes(),
      blockProof: _decodeProof(items[1].toList())
    });
  }

  function decodeExit(bytes memory rlpBytes) internal returns(Exit) {
    return _decodeExit(rlpBytes.toRlpItem().toList());
  }

  function _decodeExit(RLPReader.RLPItem[] items) private returns(Exit) {
    return Exit({
      owner: msg.sender,
      numRanges: uint32(items[0].toUint()),
      timeStart: uint256(items[1].toUint()),
      offsets: _decodeOffsets(items[2].toList()),
      coinsProof: Proof('0x','0x','0x','0x'),
      challenge: 0
    });
  }

  function _decodeOffsets(RLPReader.RLPItem[] items) private returns(uint32[]) {
    uint32[] memory arr;
    for(var i=0; i<items.length; i++){
      arr[i] = uint32(items[i].toUint());
    }
    return arr;
  }

  function decodeProof(bytes memory rlpBytes) internal returns(Proof) {
    return _decodeProof(rlpBytes.toRlpItem().toList());
  }

  function _decodeProof(RLPReader.RLPItem[] items) private returns(Proof) {
    return Proof({
      T: items[0].toBytes(),
      r: items[1].toBytes(),
      k: items[2].toBytes(),
      B: items[3].toBytes()
    });
  }

}
