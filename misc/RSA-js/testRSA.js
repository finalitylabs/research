'use strict'

const fastPow = require('./expSquaring').fastPow
const b = require("big-integer")

let p = 32416190039
let q = 32416187761
let N = b(p*q)

console.log(N)

let t = fastPow(b(1162261467), b(1060105447830), N)
console.log(t)


// Notes

// Compare javascript number implementations and exponenatiation times
// http://peterolson.github.io/BigInteger.js/benchmark/#Exponentiation

// inspecting biginteger.js pow() 