pragma solidity ^0.4.24;

library NumberTheory {

  function modPow(uint base, uint exponent, uint modulus) public pure returns (uint) {
    if(modulus == 1) return 0;
    // Assert :: (modulus - 1) * (modulus - 1) does not overflow base
    uint result = 1;
    base = base % modulus;
    while(exponent > 0) {
      if(exponent % 2 == 1)
        result = (result * base) % modulus;
      exponent = exponent / 2;
      base = (base * base) % modulus;
    }
    return result;
  }

}
