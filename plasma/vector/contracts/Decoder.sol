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

  struct Range {
    uint start;
    uint offset;
  }

  struct Ranges {
    Range[] ownedRanges;
  }

  struct Block {
    bytes A_i; // inclusion bit accumulator
    bytes A_e; // exclusion bit accumulator
    ExpProof blockProof;
  }

  struct Exit {
    address owner;
    uint32 numRanges;
    uint256 timeStart;
    uint[] starts;
    uint[] offsets;
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

  function decodeBlock(bytes memory rlpBytes) internal returns(
      bytes memory A_i,
      bytes memory A_e,
      bytes memory T,
      bytes memory r,
      bytes memory k,
      bytes memory B
  ) {
    return _decodeBlock(rlpBytes.toRlpItem().toList());
  }

  function _decodeBlock(RLPReader.RLPItem[] memory items) private returns(
    bytes memory A_i,
    bytes memory A_e,
    bytes memory T,
    bytes memory r,
    bytes memory k,
    bytes memory B
  ) {
    (
      bytes memory a,
      bytes memory b,
      bytes memory c,
      bytes memory d
    ) = _decodeProof(items[2].toList());
    return(items[0].toBytes(),items[1].toBytes(),a,b,c,d);
  }

  function decodeExit(bytes memory rlpBytes) internal returns(
    address owner,
    uint32 numRanges,
    uint256 timeStart,
    uint[] memory starts,
    uint[] memory offsets//,
    // bytes memory T,
    // bytes memory r,
    // bytes memory k,
    // bytes memory B
  ) {
    return _decodeExit(rlpBytes.toRlpItem().toList());
  }

  function _decodeExit(RLPReader.RLPItem[] memory items) private returns(
    address owner,
    uint32 numRanges,
    uint256 timeStart,
    uint[] memory starts,
    uint[] memory offsets//,
    // bytes memory T,
    // bytes memory r,
    // bytes memory k,
    // bytes memory B   
  ) {
    return(
      msg.sender,
      uint32(items[0].toUint()),
      uint256(items[1].toUint()),
      _decodeRanges(items[2].toList()),
      _decodeRanges(items[3].toList())//,
      //'0x','0x','0x','0x'
    );
  }

  function _decodeRanges(RLPReader.RLPItem[] memory items) private returns(uint[] memory) {
    uint[] memory arr;
    for(uint i=0; i<items.length; i++){
      arr[i] = items[i].toUint();
    }
    return arr;
  }

  function decodeProof(bytes memory rlpBytes) internal returns(
    bytes memory T,
    bytes memory r,
    bytes memory k,
    bytes memory B
  ) {
    (
      bytes memory a,
      bytes memory b,
      bytes memory c,
      bytes memory d
    ) = _decodeProof(rlpBytes.toRlpItem().toList());
    return(a,b,c,d);
  }

  function _decodeProof(RLPReader.RLPItem[] memory items) private returns(
    bytes memory T,
    bytes memory r,
    bytes memory k,
    bytes memory B
  ) {
    return(
      items[0].toBytes(),
      items[1].toBytes(),
      items[2].toBytes(),
      items[3].toBytes()
    );
  }

}
