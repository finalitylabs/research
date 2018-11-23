'use strict'

// exponentiation by squaring algorithm


// notes

// 2^3 = 8

// naive 
// x^8
// x*x*x*x*x*x*x*x

// requires N-1 multiplications

// x*x = x^2
// x^2*x^2 = x^4
// x^4*x^4 = x^8

// x^15

// x*x = x^2
// x*x^2 = x^3
// x^3*x^3 = x^6
// x^6*x^6 = x^12
// x^12*x^13 = x^15

// in general
// x^(a+b) = x^a * x^b

// ie 
// x^5
// 5 = 4+1
// x^5 = x^4 * x^1

// 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1

// d5 = bin 101 = 1 + 4
// d13 = bin 1101 = 8 + 4 + 1

// x^13 = x^8 * x^4 * x^1
// x*x = x^2
// x^2 * x^2 = x^4
// x^4 * x^4 = x^8


function fastPow(x, n, N) {
  if(n.equals(1)) return x
  if(n.mod(2).equals(0)) return fastPow(x.modPow(2, N), n.divide(2), N)
  return x.multiply(fastPow(x.modPow(2, N), n.divide(2), N))
}

module.exports.fastPow=fastPow