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
    uint256 offset = 32;
    uint32 prime;

    for(uint32 i = 0; i < _count; i++) {
      assembly {prime := div(mload(add(_primes, offset)),exp(256, 28))}
      primes[_start + i] = prime;
      offset += 32;
    }
  }

  function hash(bytes _data, uint32 _count) public view returns (uint32) {
    require(primes.length >= _count, "Not enough primes available!");
    uint32 index = uint32(keccak256(_data)) % _count;
    return primes[index];
  }

}
