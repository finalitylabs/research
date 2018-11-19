// Object with all possible exceptions to get from Ethereum.
module.exports.errTypes = {
  revert            : "revert",
  outOfGas          : "out of gas",
  invalidJump       : "invalid JUMP",
  invalidOpcode     : "invalid opcode",
  stackOverflow     : "stack overflow",
  stackUnderflow    : "stack underflow",
  staticStateChange : "static state change"
}

// This function checks if the promise fails with the expected exception.
module.exports.tryCatch = async function(promise, errType) {
  try { // Expects this try to fail.
      await promise;
      throw null;
  }
  catch (error) {
      // If error is undefined throw with the following error.
      assert(error, "Expected an error but did not get one");
       // If there is an error but not the type of error that we expect throw with the following error.
      assert(error.message.startsWith(PREFIX + errType), "Expected an error starting with '" + PREFIX + errType + "' but got '" + error.message + "' instead");
  }
};

const PREFIX = "VM Exception while processing transaction: ";
