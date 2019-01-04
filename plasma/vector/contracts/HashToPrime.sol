pragma solidity 0.4.24;

import {BigNumber} from "./math/BigNumber.sol";

library HashToPrime {

  function genNonPrimeWitness() public returns(uint64) {
    
  }

  function hash(bytes memory input) public returns (uint64){
    uint j = 0;
    bytes memory h_input;
    bytes32 h_output;
    bytes memory prefix = hex"0a";
    //BigNumber.instance memory prime;
    uint64 prime;
    BigNumber.instance[3] memory randomness;

    while(true){
      h_input = abi.encodePacked(prefix, j, input);
      h_output = keccak256(h_input);

      prime = uint64(h_output);

      if (isProbablePrime(prime)) {
        return prime;
      }

      if(j==200) return;
      j++;
    }
  }

  function isProbablePrime(uint128 _n) internal returns (bool) {
    //return BigNumber.is_prime(_prime, _rand);
    uint s = 1; // accuracy param
    if(_n % 2 == 0) return false; // must be odd

    bytes memory a;
    bytes memory m;
    bytes memory n;

    bytes memory b = new bytes(32);

    assembly { mstore(add(b, 32), _n) }
    n = b;
    b = new bytes(32);

    uint k=1;
    bytes memory b0;
    uint divisor;
    uint b1;
    uint phi =_n-1;
    uint _m;
    uint previous = 1;

    while(true){
      divisor = 2**k;
      if(phi%divisor != 0){
        _m=phi/previous;

        assembly { mstore(add(b, 32), _m) }
        m = b;
        b = new bytes(32);

        assembly { mstore(add(b, 32), 421) }
        a = b;
        b = new bytes(32);

        //b0 = a**m%n;
        b0 = BigNumber.modexp(a, m, n);

        if(bytesToUint(b0) == 1 || bytesToUint(b0) == phi) {
          return true; // probably prime
        }

        for(uint z=0; z<s; z++) {
          b1 = (bytesToUint(b0)**2)%_n;
          if(b1 == phi) {
            return true; // probably prime
          }

          if(b1 == 1) {
            return false; // composite number
          }
        }
        return false;
      }
      //test.push(_n);
      //test3.push('0x1337');
      previous = divisor;
      k+=1;
      if(k==8) return false;
    }
    return false;
  }

  function bytesToUint(bytes b) public returns (uint256){
    uint256 number;
    for(uint i=0;i<b.length;i++){
      number = number + uint(b[i])*(2**(8*(b.length-(i+1))));
    }
    return number;
  }
}