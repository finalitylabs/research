pragma solidity 0.4.24;

import {Ownable} from "./Ownable.sol";
import {SafeMath} from "./math/SafeMath.sol";

contract Parent is Ownable {
  using SafeMath for uint256;

  uint64 public _amt;

  uint256 constant public ASSET_DECIMALS_TRUNCATION = 10e13;
  // lowest denom (0.0001 ether), 1 ether = 10,000 coins
  // m = {0,1}^256 needs 2,560,000 primes per ether
  // for 64 bit primes this is 20.48 mb of storage.

  mapping(address => bytes32[]) private _depositHashes;
  uint[] private offsets;
  uint numRanges;
  uint totalSupply;

  event Deposit(address indexed depositer, uint64 indexed amount);

  constructor() public {
    numRanges = 0;
  }

  function submitBlock() onlyOwner {

  }

  function deposit() public payable {
    uint64 amt = uint64(msg.value/ASSET_DECIMALS_TRUNCATION);
    _amt = amt;
    uint memory _offset = 
    bytes32 hash = keccak256(abi.encodePacked(msg.sender, amt));
    _depositHashes[msg.sender].push(hash);
    emit Deposit(msg.sender, amt);
  }

}