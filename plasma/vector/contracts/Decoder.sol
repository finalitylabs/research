pragma solidity ^0.4.23;

import { RLPReader } from "./RLPReader.sol";

library Decoder {
  using RLPReader for RLPReader.RLPItem;
  using RLPReader for bytes;

  struct Block {

  }

  struct Exit {
    uint32 numRanges;
  }

  function decodeExit(bytes memory rlpBytes) internal pure returns(Exit) {
    return _decodeExit(rlpBytes.toRlpItem().toList());
  }

  function _decodeExit(RLPReader.RLPItem[] items) private pure returns(Exit) {
    return Exit({
      numRanges: uint32(items[0].toUint())
    });
  }

}
