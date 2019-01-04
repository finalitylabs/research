pragma solidity 0.4.24;

import {Ownable} from "./Ownable.sol";
import {SafeMath} from "./math/SafeMath.sol";
import {Decoder} from "./Decoder.sol";
import {HashToPrime} from "./math/HashToPrime.sol";

contract Parent is Ownable {
  using SafeMath for uint256;
  using Decoder for bytes;

  uint64 public _amt;

  uint256 constant public EXIT_TIMEOUT = 7 days;
  uint256 constant public ASSET_DECIMALS_TRUNCATION = 10e13;
  // lowest denom (0.0001 ether), 1 ether = 10,000 coins

  mapping(address => bytes32[]) private _depositHashes;
  mapping(address => uint[]) private offsets;
  mapping(uint => Decoder.Exit) public exits;
  mapping(uint => Decoder.Block) public blocks;

  uint currOffset;
  uint numExit;

  event Deposit(address indexed depositer, uint64 indexed amount, uint offset);
  event ExitSubmit();
  event ExitChallenge();
  event BlockSubmit();
  event BlockChallenge(); // assumes data availability

  constructor() public {
    currOffset = 0;
    numExit = 0;
  }

  function submitBlock(bytes memory encoded) onlyOwner {
    Decoder.Block memory _block = encoded.decodeBlock();
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

  function cancelDeposit() public {
    // todo, allow cancel before coins are accumulated and committed to a block
  }

  function startExit(bytes memory encoded) public payable {
    Decoder.Exit memory _exit = encoded.decodeExit();
    //require(_isContained(_exit.proof));
    numExit.add(1);
    _exit.timeStart = now;
    exits[numExit] = _exit; // todo, dont store proof bytes, run inclusion check
    numExit = numExit.add(1);
  }

  function finalizeExit(uint exitIndex) {
    require(now > exits[exitIndex].timeStart + EXIT_TIMEOUT);
    require(exits[exitIndex].challenge == 0);
  }

  // Challenges

  function challengeSpent() {

  }

  function requestExitProof(uint exitIndex) payable {
    // ask an exit to reveal the inclusion proof, stalling the exit until revealed
    exits[exitIndex].challenge = 1;
  }

  function registerInlcusionProof(uint exitIndex, bytes proof) {
    exits[exitIndex].proof = proof;
    exits[exitIndex].challenge = 0;
  }

  function challengeInvalidBlockProof() {

  }

  function challengeInvalidPrime(uint128 primeCheck) {
    // Provide witness that an exit is comprised of non-prime number
    uint128 _witness = HashToPrime.genNonPrimeWitness(primeCheck);
    // require exits[exitid].proof contains primeCheck
  }

  function challengeInvalidRange() {

  }

  // Utils

  function _setChallenged() {
    
  }

  function _isContained(bytes _proof) internal returns(bool) {
    // todo
  }

  function _verifyBlock(bytes _wesProof) internal returns(bool) {

  }

}
