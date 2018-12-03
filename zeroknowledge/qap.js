'use strict'

const bigInt = require("big-integer")

// x^3 + x + 5 = 35
function qeval(x) {
  let y = x.pow(3)
  return x.plus(y).plus(5)
}

console.log(qeval(bigInt(3)))

// r1cs
let x
let one
let sym_1 = x*x
let y = sym_1*x
let sym_2 = y+x
let out = sym_2+5

// vector map
// solution vector will assign these variables in this order
let v = [one, x, out, sym_1, y, sym_2]

// gate 1: sym_1 = x*x (dot product)
// check sym_1 equality
// passes if the solution vector has x in position 2, and x^2 in position 4
let a1 = [0, 1, 0, 0, 0, 0] // x
let b1 = [0, 1, 0, 0, 0, 0] // x
let c1 = [0, 0, 0, 1, 0, 0] // sym_1

// gate 2: y = sym_1*x (dot product)
// check y equality
// passes if vector 2 * 4 is equal to 5
let a2 = [0, 0, 0, 1, 0, 0] // sym_1
let b2 = [0, 1, 0, 0, 0, 0] // x
let c2 = [0, 0, 0, 0, 1, 0] // y

// gate 3: sym_2 = y+x (addition)
let a3 = [0, 1, 0, 0, 1, 0] // x + y
let b3 = [1, 0, 0, 0, 0, 0] // 1
let c3 = [0, 0, 0, 0, 0, 1] // sym_2

// gate 4: out = sym_2+5
let a4 = [5, 0, 0, 0, 0, 1] // 5 + sym_2
let b4 = [1, 0, 0, 0, 0, 0] // 1
let c4 = [0, 0, 1, 0, 0, 0] // out

let w = [1, 3, 35, 9, 27, 30]
console.log(out)