pragma solidity 0.4.24;

contract Primes {

  address public uploader;

  uint32[] public primes;

  // A witness is used to prove our users the primes uploaded by the uploader
  // are not fake.
  bytes32 public witness;

  constructor() public {
    uploader = msg.sender;
  }

  function get(uint32 _index) public view returns (uint32) {
    require(_index < primes.length, "Prime not uploaded yet!");
    return primes[_index];
  }

  function set(uint32 _start, uint32 _count, bytes _primes) public {
    require(msg.sender == uploader, "Only uploader can add primes!");
    require(primes.length == _start, "Should add primes on top of the current primes.");
    require(_primes.length == _count * 4, "Should provide 4-bytes for each prime.");

    witness =  keccak256(abi.encodePacked(witness, _primes));

    for(uint32 i = 0; i < _count; i++) {
      primes[_start + i] = _primes.getUint32(i * 4);
    }
  }

}
