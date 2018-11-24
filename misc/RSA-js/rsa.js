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

let g = bigInt(3) // empty accumulator
let p = bigInt(32416190039)
let q = bigInt(32416187761)
let N = bigInt(p.multiply(q)) // don't do this in practice, find private pq

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

x = bigInt(2*5*3*7) // adjust cofactor
console.log(isContained(bigInt(11), A, x)) // true


A = addElement(bigInt(17), A)
A = addElement(bigInt(13), A)
A = addElement(bigInt(19), A)
A = addElement(bigInt(23), A)
A = addElement(bigInt(104849), A)
A = addElement(bigInt(16369), A)
A = addElement(bigInt(29), A)
A = addElement(bigInt(1300931), A)
A = addElement(bigInt('32416187899'), A)
A = addElement(bigInt('32416188517'), A)
A = addElement(bigInt('32416188647'), A)
A = addElement(bigInt('32416189391'), A)
A = addElement(bigInt('32416189459'), A)
A = addElement(bigInt('32416189469'), A)

console.log(A.toString())

// prove 29 is in the accumulator
x = bigInt(2)
  .multiply(3)
  .multiply(5)
  .multiply(7)
  .multiply(11)
  .multiply(13)
  .multiply(17)
  .multiply(19)
  .multiply(23)
  .multiply(104849)
  .multiply(16369)
   //
  .multiply(1300931)
  .multiply('32416187899')
  .multiply('32416188517')
  .multiply('32416188647')
  .multiply('32416189391')
  .multiply('32416189459')
  .multiply('32416189469')


console.log(isContained(bigInt(29), A, x)) // true


let A2 = A
A2 = addElement(bigInt(101), A2)
A2 = addElement(bigInt(103), A2)
A2 = addElement(bigInt(107), A2)
A2 = addElement(bigInt(29), A2)

let x2 = bigInt(103)
  .multiply(107)
  .multiply(101)
  .multiply(29)
  //.multiply(29)

x2 = x2.multiply(x)

x = x.multiply(103)
  .multiply(107)
  .multiply(101)
  .multiply(29)
  //.multiply(29)


console.log(x2.toString())

let _A2 = A.modPow(x2, N)

//x2 = A.modPow(_A2, N)
console.log(x2.toString())
console.log(A.toString())

console.log(isContained(bigInt(29), A2, x2)) // true
console.log(x.toString())
console.log(N.toString())
// // add multiple txs to the accumulator
// let txlist = [bigInt(29), bigInt(31), bigInt(37)]

// A = addElements(txlist, A)
// // prove 7 is in the accumulator
// x = bigInt(2*3*5*11*13*17*19*23*29*31*37*104849)
// console.log(isContained(bigInt(7), A, x)) // true


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

let a = 29 // new v, element to get inclusion proof on
//V2 setup
let h = g.modPow(a, N)

let B = bigInt(utils.hexToNumberString(utils.soliditySha3(g.toString(),A2.toString(), h.toString())))
// B may be 64bytes and too big to store in web3 BN
//let b = h.pow(x.divide(B))
let b = h.modPow(x.divide(B), N)
let r = x.mod(B)

let proof = {b:b,r:r}

console.log(verifyCofactor(proof, a, A2))
//console.log(proof)
// let z = b.modPow(B, N)
// let c = h.modPow(r, N)

// let c1 = z.multiply(c).mod(N)
// let c2 = A.mod(N)

// // //V1 setup
// // let h = g.pow(a)
// // let z = h.pow(x)
// // let B = bigInt(utils.hexToNumberString(utils.sha3(h.toString()))).mod(N)


let _p = getInclusionProof(bigInt(29), 0, A2)
console.log(verifyCofactor(_p, a, A2))

function addElement(element, accumulator) {
  console.log('adding element: '+element+' to accumulator: '+accumulator.toString())
  return accumulator.modPow(element.toString(), N.toString())
}

function addElements(elements, accumulator) {
  console.log('adding list of txs to accumulator')
  let accumElems = bigInt(1)
  for(var i=0; i<elements.length; i++) {
    accumElems = accumElems.multiply(elements[i])
  }
  return accumulator.modPow(accumElems.toString(), N.toString())
}

function isContained(element, accumulator, cofactor) {
  let res = g.modPow(element.multiply(cofactor).toString(), N.toString())
  // console.log(element.multiply(cofactor).toString())
  // console.log(N.toString())
  // console.log(res.toString())
  return res.equals(accumulator.toString())
}

function verifyCofactor(proof, v, A){
  let h = g.modPow(v, N)
  let B = bigInt(utils.hexToNumberString(utils.soliditySha3(g.toString(), A.toString(), h.toString())))
  let z = proof.b.modPow(B, N)
  let c = h.modPow(proof.r, N)

  let c1 = z.multiply(c).mod(N)
  let c2 = A.mod(N)
  return c1.equals(c2)
}

// as per Xuanji's suggestion, let's keep x local to the operator, 
// generate an inclusion proof for a single given element
// uses wesoloski proof of exponentiation so that recipients 
// of the proof don't need to witness the entire [g...A]
// currently only works for a prime included once
function getInclusionProof(v, block, _A){
  let h = g.modPow(v, N)
  let B = bigInt(utils.hexToNumberString(utils.soliditySha3(g.toString(),_A.toString(), h.toString())))
  // get cofactor somehow, perhaps check full tx records of request A range and... or
  // compute x given (g, A, v). Can't do this given mod N
  // grab transactions and generate x

  let _x = getCofactor(0, 1)

  let b = h.modPow(_x.divide(B), N)
  let r = _x.mod(B)
  return {b:b,r:r}
}

function getExclusionProof(element, blockRange) {

}

function getCofactor(endBlock) {
  // todo, grab stored transactions to generate cofactor
  return x
}

function storeCofactor(x, endBlock) {

}

// js Math.log return the ln(x) we must convert
// log_b(x) = ln(x) / ln(b)
function logB(val, b) {
  console.log('log A = ' + Math.log(val) / Math.log(b))
  return Math.round(Math.log(val) / Math.log(b))
}

class RSAaccumulator {
  constructor(g, N) {
    this.g = bigInt(g)
    this.N = bigInt(N)
    this.A = this.g
    this.blocks = []
  }

  addElement(v) {
    v = bigInt(v)
    console.log('adding element: '+v+' to accumulator: '+this.A.toString())
    this.A = this.A.modPow(v.toString(), this.N.toString())    
  }

  addBlock(block) {
    console.log('adding list of txs to accumulator')
    let accumElems = bigInt(1)
    for(var i=0; i<block.length; i++) {
      console.log('adding element: '+block[i]+' to accumulator: '+this.A.toString())
      accumElems = accumElems.multiply(block[i])
    }
    this.A = this.A.modPow(accumElems.toString(), this.N.toString())
    block.unshift(this.A.toString())
    this.blocks.push(block)
  }

  getAccumulator() {
    return this.A
  }

  getAccumulatorByRange(e) {
    return bigInt(this.blocks[e][0])
  }

  _isContained(element, cofactor, _A) {
    element = bigInt(element)
    let res = this.g.modPow(element.multiply(cofactor).toString(), this.N.toString())
    return res.equals(_A.toString())
  }

  _getCofactor(v, start, end) {
    let xv = bigInt(1)

    for(var i=start; i<=end; i++) {
      let l = this.blocks[i].length
      for(var j=1; j<l; j++) {
        xv = xv.multiply(this.blocks[i][j])
      }
    }
    return xv.divide(v)
  }

  // as per Xuanji's suggestion, let's keep x local to the operator, 
  // generate an inclusion proof for a single given element
  // uses wesoloski proof of exponentiation so that recipients 
  // of the proof don't need to witness the entire [g...A]
  getInclusionProof(v, s, e){
    let h = this.g.modPow(v, this.N)
    let B = bigInt(utils.hexToNumberString(utils.soliditySha3(this.g.toString(),this.A.toString(), h.toString())))
    // get cofactor somehow, perhaps check full tx records of request A range and... or
    // compute x given (g, A, v). Can't do this given mod N
    // grab transactions and generate x
    let _x = this._getCofactor(v, s, e)
    let b = h.modPow(_x.divide(B), this.N)
    let r = _x.mod(B)
    return {b:b,r:r,A:this.blocks[e][0]}
  }

  // verifies the cofactor proof for a given range
  verifyCofactor(proof, v){
    let h = this.g.modPow(v, this.N)
    let B = bigInt(utils.hexToNumberString(utils.soliditySha3(this.g.toString(), proof.A, h.toString())))

    let z = proof.b.modPow(B, N)
    let c = h.modPow(proof.r, N)

    let c1 = z.multiply(c).mod(N)
    let c2 = bigInt(proof.A).mod(N)
    return c1.equals(c2)
  }

}

module.exports= RSAaccumulator