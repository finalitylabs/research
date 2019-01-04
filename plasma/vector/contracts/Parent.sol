pragma solidity 0.4.24;

import {Ownable} from "./Ownable.sol";
import {SafeMath} from "./math/SafeMath.sol";
import {Decoder} from "./Decoder.sol";

contract Parent is Ownable {
  using SafeMath for uint256;
  using Decoder for bytes;

  uint64 public _amt;

  uint256 constant public ASSET_DECIMALS_TRUNCATION = 10e13;
  // lowest denom (0.0001 ether), 1 ether = 10,000 coins

  mapping(address => bytes32[]) private _depositHashes;
  mapping(address => uint[]) private offsets;
  mapping(uint => Decoder.Exit) public exits;
  uint currOffset;
  uint numExit;

  event Deposit(address indexed depositer, uint64 indexed amount, uint offset);

  constructor() public {
    currOffset = 0;
    numExit = 0;
  }

  function submitBlock(bytes memory encoded) onlyOwner {

  }

  function deposit() public payable {
    uint64 amt = uint64(msg.value/ASSET_DECIMALS_TRUNCATION);
    _amt = amt;
    currOffset = currOffset.add(_amt);
    offsets[msg.sender].push(currOffset);
    bytes32 hash = keccak256(abi.encodePacked(msg.sender, amt, currOffset));
    _depositHashes[msg.sender].push(hash);
    emit Deposit(msg.sender, amt, currOffset);
  }

  function startExit(bytes memory encoded) public payable {
    Decoder.Exit memory _exit = encoded.decodeExit();
    require(_isContained(_exit.proof));
    numExit.add(1);
    _exit.timeStart = now;
    exits[numExit] = _exit;
    numExit = numExit.add(1);
  }

  function finalizeExit() {

  }

  // Challenges

  function challengeSpent() {

  }

  function challengeInvalidBlockProof() {

  }

  function challengeInvalidPrimes() {
    // Provide witness that an exit is comprised of non-prime number
  }

  function challengeInvalidRange() {

  }

  // Utils

  function _setChallenged() {
    
  }

  function _isContained(bytes _proof) internal returns(bool) {
    // todo
  }

}
