pragma solidity 0.5.0;

import {Ownable} from "./Ownable.sol";
import {SafeMath} from "./math/SafeMath.sol";
import {Decoder} from "./Decoder.sol";
import {HashToPrime} from "./math/HashToPrime.sol";
import {BigNumber} from "./math/BigNumber.sol";

contract Parent is Ownable {
  using SafeMath for uint256;
  using Decoder for bytes;

  uint64 public p; //testing

  uint64 public _amt;

  uint256 constant public EXIT_TIMEOUT = 7 days;
  uint256 constant public ASSET_DECIMALS_TRUNCATION = 10e17;

  bytes public CRS_g;
  bytes public CRS_N;
  // lowest denom (0.0001 ether), 1 ether = 10,000 coins

  mapping(address => bytes32[]) private _depositHashes;
  mapping(address => Decoder.Ranges) ranges; // todo: deal with splitting 
  mapping(uint => Decoder.Exit) exits;
  mapping(uint => Decoder.Block) blocks;

  uint currOffset;
  uint public numExits;
  uint blockNum;

  event Deposit(address indexed depositer, uint64 indexed amount, uint offset);
  event ExitSubmit(uint indexed time, uint indexed start, address indexed exiter);
  event ExitChallenge();
  event BlockSubmit();
  event BlockChallenge(); // assumes data availability

  constructor(bytes memory _g, bytes memory _N) public {
    CRS_N = _N;
    CRS_g = _g;
    currOffset = 0;
    numExits = 0;
  }

  function submitBlock(bytes memory encoded) public onlyOwner {
    (
      bytes memory _a_i,
      bytes memory _a_e,
      bytes memory _t,
      bytes memory _r,
      bytes memory _k,
      bytes memory _b
    ) = Decoder.decodeBlock(encoded);

    Decoder.Block memory _block;
    _block.A_i = _a_i;
    _block.A_e = _a_e;
    // perhaps to optimistic block proposal and don't store proof unless challenged
    _block.blockProof.T = _t;
    _block.blockProof.r = _r;
    _block.blockProof.k = _k;
    _block.blockProof.B = _b;

    blockNum = blockNum.add(1);
    blocks[blockNum] = _block;
    // todo verify proofs?
  }

  function deposit() public payable {
    uint64 amt = uint64(msg.value/ASSET_DECIMALS_TRUNCATION);
    _amt = amt;
    Decoder.Range memory _range;
    _range.start = currOffset;
    currOffset = currOffset.add(_amt);
    _range.offset = amt;
    ranges[msg.sender].ownedRanges.push(_range);
    bytes32 hash = keccak256(abi.encodePacked(msg.sender, amt, currOffset));
    _depositHashes[msg.sender].push(hash);
    emit Deposit(msg.sender, amt, currOffset);
  }

  function cancelDeposit(bytes memory encoded) public {
    // todo, allow cancel before coins are accumulated and committed to a block
  }

  function startExit(bytes memory encoded) public payable {
    (
      address a, //owner,
      uint b, //numRanges,
      uint c, //timeStart,
      uint s, // start indicies,
      uint d // offsets,
      // bytes memory e, // T,
      // bytes memory f, //r,
      // bytes memory g, //k,
      // bytes memory h //B,
    ) = Decoder.decodeExit(encoded);
    //require(_isContained(_exit.proof));
    // todo add bond check
    numExits = numExits.add(1);

    Decoder.Exit memory _exit;
    _exit.timeStart = now;
    _exit.owner = a;
    _exit.numRanges = b;
    _exit.starts = s;
    _exit.offsets = d;

    // _exit.coinsProof.T = e;
    // _exit.coinsProof.r = f;
    // _exit.coinsProof.k = g;
    // _exit.coinsProof.B = h;

    exits[numExits] = _exit; // dont store proof bytes or run inclusion check
    emit ExitSubmit(now, _exit.starts, msg.sender);
  }

  function getExit(uint index) public view returns (
    address owner,
    uint numRanges,
    uint timeStart,
    uint rangeStarts,
    uint rangeOffsets
  ){
    Decoder.Exit memory _exit = exits[index];
    return (
      _exit.owner,
      _exit.numRanges,
      _exit.timeStart,
      _exit.starts,
      _exit.offsets
    );  
  }

  function cancelExit(uint exitIndex) public {
    require(exits[exitIndex].owner == msg.sender);
    // require exit is active and not in challenge
    delete exits[exitIndex];
    numExits = numExits.sub(1);
  }

  function finalizeExit(uint exitIndex) public payable {
    //require(now > exits[exitIndex].timeStart + EXIT_TIMEOUT);
    //require(exits[exitIndex].challenge == 0);
    // todo delete exit anyway if challenge is set
    // delete offsets and refund gas
    // send ether 
    Decoder.Exit memory _exit = exits[exitIndex];
    numExits = numExits.sub(1);
    uint _amt = _exit.offsets.mul(ASSET_DECIMALS_TRUNCATION);
    address(uint160(_exit.owner)).transfer(_amt);
    delete exits[exitIndex];
    delete ranges[msg.sender];
  }

  // Challenges

  function challengeSpend(bytes memory txData, uint64[256] memory index, uint blockNum) public {
    // invalidate block accumulator by showing that a given index
    // was altered without the proper signature witness
  }

  function requestExitProof(uint exitIndex) public payable {
    // ask an exit to reveal the inclusion proof, stalling the exit until revealed
    // todo add bond check
    //exits[exitIndex].challenge = 1;
  }

  function registerInlcusionProof(uint exitIndex, bytes memory proof) public {
    (
      bytes memory a,
      bytes memory b,
      bytes memory c,
      bytes memory d
    ) = Decoder.decodeProof(proof);

    //exits[exitIndex].coinsProof.T = a;
    //exits[exitIndex].coinsProof.r = b;
    //exits[exitIndex].coinsProof.k = c;
    //exits[exitIndex].coinsProof.B = d;
    //exits[exitIndex].challenge = 0;
  }

  function challengeInvalidInclusionProof(uint exitIndex) public {
    // check (g^w)^x = A
    // NI-PoKE* check
    // b^B * h^r = A
    Decoder.Block memory _block = blocks[blockNum];
    bytes memory A_i = _block.A_i;
    bytes memory A_e = _block.A_e;

    require(_isContained(A_i, A_e, exitIndex));
  }

  
  function challengeInvalidExitHTP(uint exitIndex) public {
    bytes memory h_input;
    //h_input = abi.encodePacked(CRS_g, exits[exitIndex].coinsProof.T);
    //bytes32 i = keccak256(h_input);
    uint64 _B = HashToPrime.hash(abi.encodePacked(exitIndex));
    p = _B;
    //require(_B == uint64(exits[exitIndex].coinsProof.B)); // todo bytesToUint64
  }

  // perhaps do check on block publish
  function challengeInvalidBlockProof(uint prevBlock) public {
    // check that A_t^x = A, where x is provided as a wes18 proof
    // b^B * g^r = A
    Decoder.Block memory _block = blocks[prevBlock];
    Decoder.ExpProof memory _proof = _block.blockProof;
    // bytes memory A_t = _block.A_i;
    // todo _verifyBlock
  }

  function challengeInvalidPrime(uint128 index) public {
    // take the index in question, see that it is not in the exit range
    // do one hash to prime on coin index htp to get prime
    // require exits[exitid].proof contains prime
  }

  function challengeNotPrime(uint128 primeCheck) public {
    // Provide witness that an exit is comprised of non-prime number
    //uint128 _witness = HashToPrime.genNonPrimeWitness(primeCheck);
    require(!HashToPrime.isProbablePrime(primeCheck));
    // require exits[exitid].proof contains primeCheck
  }

  function challengeInvalidRange() public {
    // show that the indicies presented in exit are not valid
  }

  // Utils

  // check coin proof
  function _isContained(bytes memory _A_i, bytes memory _A_e, uint exitIndex) internal returns(bool) {
    // bytes memory b = BigNumber.modexp(CRS_g, exits[exitIndex].coinsProof.k, CRS_N);
    // BigNumber.instance memory _b;
    // _b.val = BigNumber.modexp(b, exits[exitIndex].coinsProof.B, CRS_N);
    // BigNumber.instance memory _r;
    // _r.val = BigNumber.modexp(CRS_g, exits[exitIndex].coinsProof.r, CRS_N);
    // BigNumber.instance memory _z;

    // BigNumber.instance memory _N;
    // _N.val = CRS_N;
    // _z = BigNumber.modmul(_b, _r, _N);

    //return _accumulator == _z.val; //todo byte compare large numbers
  }

  // check block update proof
  function _verifyBlock(bytes memory _prevAccum, uint _blockNum) internal returns(bool) {
    bytes memory b = BigNumber.modexp(_prevAccum, blocks[_blockNum].blockProof.k, CRS_N);
    BigNumber.instance memory _b;
    _b.val = BigNumber.modexp(b, blocks[_blockNum].blockProof.B, CRS_N);
    BigNumber.instance memory _r;
    _r.val = BigNumber.modexp(_prevAccum, blocks[_blockNum].blockProof.r, CRS_N);
    BigNumber.instance memory _z;

    BigNumber.instance memory _N;
    _N.val = CRS_N;
    _z = BigNumber.modmul(_b, _r, _N);
    //return blocks[blockNum].accumulator == _z.val; //todo byte compare large numbers
  }

}
