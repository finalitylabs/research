pragma solidity 0.4.24;

/*
exitDeposit (Create an exit for a deposit which is (assumed) to be in block 0)
exitTransaction (Create an exit for a tx in some block)

cancelExit (Provide a tx that says the coin is spent, and cancel the exit immediately)

challenge (Some user submits a tx on your coin before your tx, the exit goes in CHALLENGE state, after some timeout, the exit gets cancelled)
respondChallenge (Show him that tx is spent, and revive the exit again)
*/



contract PlasmaPrimeflow {

  address public operator;

  //------------------------------------------------------------------

  // Representing a range of coins
  struct Range {
    uint256 start;
    uint256 offset;
  }

  //------------------------------------------------------------------

  struct Transaction {
    Range coins;
    address recipient;
    uint256[] previousBlocks; // Indices of the blocks where parent transactions reside.
    uint256 primeIndex; // Index of the prime assigned to this transaction.
  }

  //------------------------------------------------------------------

  struct Block {
    uint256 accumulator;
    bytes32 root; // Hash of the Merkle-Sum-Tree.
  }
  Block[] public blocks;

  //------------------------------------------------------------------

  struct Deposit {
    address owner; // Initial owner of this range.
    Range coins;
  }
  Deposit[] public deposits;
  uint256 public coinsDeposited;

  //------------------------------------------------------------------

  struct Challenge {
    uint256 finalAt; // Till when you can respond to this challenge.
    uint256 blockIndex; // Index of the block challenging transaction exists.
    uint256 recipeint; // Recipient of the challenging transaction.
    Range coins; // Which part of the coins being exited are being challenged.
  }

  struct Exit {
    uint256 blockIndex; // Index of the block the exiting transaction exists.
    address exitor; // Who made this exit.
    uint256 prime; // prime of the transaction being exited.
    Range coins; // Coins to exit.
    uint256 finalAt; // block.timestamp when the exit was made + EXIT_TIMEOUT.
    bool invalid; // Whether this exit has been invalidated or not.
    Challenge challenge; // Each exit can be challenged once
  }
  // Exit list. (No two exits should overlap, given a range, we should be find an overlapping exit in O(logn) time)
  Exit[] public exits;

  //------------------------------------------------------------------

  // To store which coins are exited and prevent exiting them again.
  Range[] public exiteds;

  // Returns if the supplied range of coins exist and are not exited.
  function coinExists(Range _coins)
  public
  view
  returns (bool) {
   // Check if the coins exist.
   if(_coins.start + _coins.offset > coinsDeposited)
      return false;

   // Check if part/all of the coins are not exited yet.
    for(uint256 i = 0; i < exiteds.length; i++)
      if(_coins.intersectsWith(_exiteds[i]))
        return false;

    return true;
  }

  //------------------------------------------------------------------

  constructor() public {
    operator = msg.sender;
    coinsDeposited = 0;

   // Let's say all deposits are stored in block 0, so they have highest
   // priority when finalizing exits.
    blocks.push(Block(uint256(3), bytes32(0)));
  }

  function deposit()
  public
  payable {
    require(msg.value > 0, "Deposit amount should be > 0.");
    require(msg.sender != address(0), "Invalid sender address.");

    // Reserve `msg.value` number of coins, starting from `coinsDeposited`
    deposits.push(Deposit(msg.sender, Range(coinsDeposited, msg.value)));
    coinsDeposited = coinsDeposited.add(msg.value);
  }

  function submitBlock(uint256 _index, bytes32 _root, uint256 _accumulator)
  public
  onlyOperator {
    require(blocks.length == _index, "Block index mismatch.");
    blocks.push(Block(_accumulator, _root));
  }

  modifier bonded() {
    require(msg.value == EXIT_BOND);
    _;
  }

  // Use this function if you want to exit a deposit transaction.
  function exitDeposit(uint256 _depositId)
  public
  bonded
  payable {
    Deposit storage deposit = deposits[_depositId];
    require(deposit.owner == msg.sender, "You are not the owner.");
    require(!exitExists(deposit.coins), "Coins are already being exited! Try to challenge them!");
    uint256 finalAt = block.timestamp.add(challengeTimeout);
    // 0 is the block index, meaning that we are creating an exit for a deposit.
    // (As we have considered all deposit transactions are stored in block 0)
    exits.push(Exit(0, deposit.owner, deposit.coins, finalAt, false));
  }

  function exitTransaction(bytes _txBytes, bytes _proof, uint256 _targetBlock)
  public
  bonded
  payable {
    Transaction memory transaction = decodeTransaction(_txBytes);
    require(transaction.recipient == msg.sender, "You are not the owner.");
    require(!exitExists(transaction.coins), "Coins are already being exited! Try to challenge them!");
    bytes32 h = hashTransaction(transaction);
    require(blocks[_targetBlock].hasHash(h, _proof));
    uint256 finalAt = block.timestamp.add(EXIT_TIMEOUT);
    exits.push(Exit(_targetBlock, transaction.recipient, transaction.coins, finalAt, false));
  }


  function cancelExit(uint256 _exitId, bytes _txBytes, bytes _proof, uint256 _rsaProof, bytes _signature, uint256 _targetBlock)
  public {
    Transaction memory transaction = decodeTransaction(_txBytes);
    bytes32 h = hashTransaction(transaction);
    require(blocks[_targetBlock].hasHash(h, _proof));

    Exit storage exit = exits[_exitId];
    require(exit.exitor != address(0), "Exit does not exist.");
    require(!exit.invalid, "Already invalid.");
    require(transaction.prevBlockIndices.has(exit.blockIndex), "Your transaction should refer to the blockIndex of the Exit being challenged.");
    require(blocks[_targetBlock].accumulator.hasPrime(exit.prime, _rsaProof));
    require(exit.coins.intersectsWith(transaction.coins), "Your transaction and the exit being challenged should have intersection with each other.");
    require(h.signedBy(exit.exitor));
    exit.invalid = true;

    msg.sender.transfer(EXIT_BOND);
  }

  function challengeExit(uint256 _exitId, bytes _txBytes, bytes _proof, uint256 _targetBlock)
  public
  bonded
  payable {
    Exit storage exit = exits[_exitId];
    require(exit.finalAt != 0, "Exit does not exist!");
    require(!exit.invalid && exit.challenge.finalAt == 0, "Already challenged!");

    Transaction memory t = decodeTransaction(_txBytes);
    bytes32 h = hashTransaction(t);
    require(blocks[_targetBlock].hasHash(h, _proof));

    require(exit.coins.intersectsWith(t.coins), "Your transaction and the exit being challenged should have intersection with each other.");

    uint256 finalAt = block.timestamp.add(CHALLENGE_TIMEOUT);
    Range coin = exit.coins.intersection(t.coins);
    exit.challenge = Challenge(finalAt, _targetBlock, transaction.recipient, coins);
  }

  function respondChallenge(uint256 _exitId, bytes _txBytes, bytes _proof. uint256 _rsaProof, uint256 _targetBlock)
  public
  bonded
  payable {
    Transaction memory transaction = decodeTransaction(_txBytes);
    bytes32 h = hashTransaction(transaction);
    require(blocks[_targetBlock].hasHash(h, _proof));

    Exit storage exit = exits[_exitId];
    require(exit.challengeRange.intersectsWith(transaction.coins), "Your transaction and the challenge being responded should have intersection with each other.");
    require(transaction.prevBlockIndices.has(exit.challengeBlock), "Your transaction should refer to the blockIndex of the challenge being responded.");
    require(blocks[_targetBlock].accumulator.hasPrime(exit.prime, _rsaProof));
    require(h.signedBy(challengeOwner));

    exit.challenge.finalAt = 0; // Revive exit by cancelling the challenge.
  }


  function finalizeExits()
  public  {
    uint256 ts = block.timestamp;

    for(uint256 i = 0; i < exits.length; i++) {
      Exit memory exit = exits[i];

      if(exit.challenge.finalAt != 0 && timestamp > exit.challenge.finalAt)
        exit.invalid = true;

      if(!exit.invalid && timestamp > exit.finalAt && coinExists(exit.coins)) {
        uint256 exitAmount = exit.coins.offset.add(EXIT_BOND);
        exit.exitor.transfer(exitAmount);
        exiteds.push(exit.coins); // Prevent the exited coins being exited again.
      }
    }
  }

}
