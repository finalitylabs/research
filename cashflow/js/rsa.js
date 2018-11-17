'use strict'

// TODO Wesolowski proof of exponent knowledge scheme

var bigInt = require("big-integer")

let g = 3 // empty accumulator
let p = 32416190039
let q = 32416187761
let N = bigInt(p*q) // don't do this in practice, find private pq

let U = 2*3*5*7 // 210
let A = bigInt(g).modPow(U,N)

console.log(bigInt(g**U)%N)
console.log(N.toString())
console.log(A.toString())

let v = bigInt(5)
let x = 2*3*7

console.log(isContained(v, A, x)) // true
console.log(isContained(bigInt(11), A, x)) // false

// inclusion proof for v=5
// P = G^v % N

// pi = A^1/v is in G

// (g^v)x = A
// ex 
// cofactor = 2*3*7
// A = 3^U
// U = v*cofactor
// 3^5*42 = A

function addElement(element, accumulator) {
  return accumulator.pow(element)
}

function addElements(elements, accumulator) {
  let accumElems = bigInt(1)
  for(var i=0; i<elements.length; i++) {
    accumElems = accumElems.multiply(elements[i])
  }
  return accumulator.pow(accumElems)
}

function isContained(element, accumulator, cofactor) {
  let res = bigInt(g).modPow(element.multiply(cofactor), N)
  return res.equals(accumulator)
}

function getInclusionProof(element, block){

}

function getExclusionProof(element, blockRange) {

}