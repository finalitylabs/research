'use strict'

const fastPow = require('./expSquaring').fastPow
const b = require("big-integer")

let a = b(123213123)
a.pow(213213123123213)

let t = fastPow(b(1234), b(1060))
console.log(t)


// Notes

// Compare javascript number implementations and exponenatiation times
// http://peterolson.github.io/BigInteger.js/benchmark/#Exponentiation

// inspecting biginteger.js pow() 