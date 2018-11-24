'use strict'

const RSA = require('./rsa')
const b = require("big-integer")

let acc = new RSA(3, '1050809302800481912679')
//console.log(accumulator)

//acc.addElement(5)
console.log('-------')

let b0 = [2, 3, 5]
let b1 = [16369, 104849, 1300931, 7]
let b2 = [7, 5, 16369, 104849, 1300931, '32416187899', '32416188517', '32416188647', '32416189391', '32416189459', '32416189469']

acc.addBlock(b0)
let A = acc.getAccumulator()

console.log(acc._isContained(5, acc._getCofactor(5, 0, 0).toString(), A))
console.log(acc._isContained(7, acc._getCofactor(7, 0, 0).toString(), A))

let expProof = acc.getInclusionProof(2,0,0)
//console.log(expProof)
console.log(acc.verifyCofactor(expProof, 2))

acc.addBlock(b1)
A = acc.getAccumulator()
A = acc.getAccumulatorByRange(1)

expProof = acc.getInclusionProof(1300931,0,1)
console.log(acc.verifyCofactor(expProof, 1300931))

console.log(acc._isContained(7, acc._getCofactor(7, 0, 0).toString(), A))
console.log(acc._isContained(5, acc._getCofactor(5, 0, 1).toString(), A))
console.log(acc._isContained(1300931, acc._getCofactor(1300931, 0, 1).toString(), A))

acc.addBlock(b2)

A = acc.getAccumulatorByRange(2)

expProof = acc.getInclusionProof('32416188647',0,2)
console.log(acc.verifyCofactor(expProof, '32416188647'))
console.log(expProof)

console.log(acc._isContained(25, acc._getCofactor(25, 0, 2).toString(), A))
console.log(acc._isContained('32416188647', acc._getCofactor('32416188647', 0, 2).toString(), A))