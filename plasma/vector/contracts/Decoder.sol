pragma solidity ^0.4.23;

import { RLPReader } from "./RLPReader.sol";

library Decoder {
  using RLPReader for RLPReader.RLPItem;
  using RLPReader for bytes;

  struct Block {
    bytes accumulator;
    bytes wesProof;
  }

  struct Exit {
    uint32 numRanges;
    uint256 timeStart;
    uint32[] offsets;
    bytes proof;
  }

  function decodeBlock(bytes memory rlpBytes) internal returns(Block) {
    return _decodeBlock(rlpBytes.toRlpItem().toList());
  }

  function _decodeBlock(RLPReader.RLPItem[] items) private returns(Block) {
    return Block({
      accumulator: items[0].toBytes(),
      wesProof: items[1].toBytes()
    });
  }

  function decodeExit(bytes memory rlpBytes) internal returns(Exit) {
    return _decodeExit(rlpBytes.toRlpItem().toList());
  }

  function _decodeExit(RLPReader.RLPItem[] items) private returns(Exit) {
    return Exit({
      numRanges: uint32(items[0].toUint()),
      timeStart: uint256(items[1].toUint()),
      offsets: _decodeOffsets(items[2].toList()),
      proof: items[3].toBytes()
    });
  }

  function _decodeOffsets(RLPReader.RLPItem[] items) private returns(uint32[]) {
    uint32[] memory arr;
    for(var i=0; i<items.length; i++){
      arr[i] = uint32(items[i].toUint());
    }
    return arr;
  }

}
