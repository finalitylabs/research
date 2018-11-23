'use strict'

const bigInt = require("big-integer")
const utils = require('web3-utils')

// TODO Wesolowski proof of exponent knowledge scheme

// for generator g, element to be proven included/excluded v
// let x = cofactor of v
// let h = g^v, z = h^x
// B = hash(h,z) mod N
// b = h^floor(x/B)
// r = x mod B
//
// proof of exponent knowledge = (b, z)
// verification: 
// b^B * h^r = z
// z = h^B*floor(x/B)+x mod B = h^x
//
// exclusion proof ov v in [g....A]
// prove r is known for 0 < r < v where A * g^r is a know power of g^v
// ie
// prove 7 is not a part of [g...A]
// let r = 3 (check) 0 < 3 < 7
// 

let g = bigInt(3) // empty accumulator
let p = 32416190039
let q = 32416187761
let N = bigInt(p*q) // don't do this in practice, find private pq

let U = 2*3*5*7 // 210
let A = bigInt(g).modPow(U,N)

// inclusion proof for v=5
// P = G^v % N

// pi = A^1/v is in G

// (g^v)x = A
// ex 
// cofactor = 2*3*7
// A = 3^U
// U = v*cofactor
// 3^5*42 = A


let v = bigInt(5)
let x = bigInt(2*3*7)

console.log(isContained(v, A, x)) // true
console.log(isContained(bigInt(11), A, x)) // false

A = addElement(bigInt(11), A)

x = bigInt(2*3*5*7) // adjust cofactor
console.log(isContained(bigInt(11), A, x)) // true


A = addElement(bigInt(13), A)
A = addElement(bigInt(17), A)
A = addElement(bigInt(19), A)
A = addElement(bigInt(23), A)

// prove 3 is in the accumulator
x = bigInt(2*5*7*11*13*17*19*23)
console.log(isContained(bigInt(3), A, x)) // true

// add multiple txs to the accumulator
let txlist = [bigInt(29), bigInt(31), bigInt(37)]

A = addElements(txlist, A)
// prove 7 is in the accumulator
x = bigInt(2*3*5*11*13*17*19*23*29*31*37)
console.log(isContained(bigInt(7), A, x)) // true


// wesoloski proof of exponentiation
// V1
// let h=g^v, z=h^x, B=hash(h,z)modN
// b=h^floor(x/B)
// r=xmodB
// proof=(b,z,r)
// check b^B*h^r=z and b^B*h^r=h^B*floor(x/B)+xmodB

// or
// V2
// h=g^vmodN, B=hash(g,A,h), b=h^floor(x/B), r=xmodB
// proof = (b,r)
// check b^B*h^r = AmodN

let a = 19 // new v, element to get inclusion proof on
//V2 setup
let h = g.modPow(a, N)

let B = bigInt(utils.hexToNumberString(utils.soliditySha3(g.toString(),A.toString(), h.toString())))
// B may be 64bytes and too big to store in web3 BN
let b = h.pow(x.divide(B))
let r = x.mod(B)

let proof = {b:b,r:r}
let z = b.pow(B)
//let c = h.pow(r)

// //V1 setup
// let h = g.pow(a)
// let z = h.pow(x)
// let B = bigInt(utils.hexToNumberString(utils.sha3(h.toString()))).mod(N)


console.log(h.toString())
console.log(r.toString())
console.log(x.toString())
console.log(B.toString())
console.log(b.toString())



function addElement(element, accumulator) {
  console.log('adding element: '+element+' to accumulator: '+accumulator)
  return accumulator.modPow(element, N)
}

function addElements(elements, accumulator) {
  console.log('adding list of txs to accumulator')
  let accumElems = bigInt(1)
  for(var i=0; i<elements.length; i++) {
    accumElems = accumElems.multiply(elements[i])
  }
  return accumulator.modPow(accumElems, N)
}

function isContained(element, accumulator, cofactor) {
  let res = bigInt(g).modPow(element.multiply(cofactor), N)
  return res.equals(accumulator)
}

function verifyCofactor(proof, v, A){
  return proof.b.pow()
}
// generate an inclusion proof for a single given element
// uses wesoloski proof of exponentiation so that recipients 
// of the proof don't need to witness the entire [g...A]
function getInclusionProof(element, block, accumulator){

}

function getExclusionProof(element, blockRange) {

}