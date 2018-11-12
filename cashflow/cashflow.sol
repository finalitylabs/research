pragma solidity 0.4.24;

contract PlasmaCashflow {

  address public operator;

  //------------------------------------------------------------------

  // Representing a range of coins
  struct CoinRange {
    uint256 start;
    uint256 offset;
  }

  //------------------------------------------------------------------

  struct Transaction {
    CoinRange coins;
    uint256[] prevTxBlockIndices;
    address newOwner;
  }

  //------------------------------------------------------------------

  struct Block {
    bytes32 root; // Hash of the Merkle-Sum-Tree.
    uint256 count; // Size of the Merkle-Sum-Tree. (Number of coins deposited till this block)
    uint256 timestamp; // block.timestamp when this block was submitted.
  }
  // Number of blocks submitted.
  uint256 public height;
  mapping(uint256 => Block) public blocks;

  //------------------------------------------------------------------

  struct Deposit {
    address owner; // Who made this deposit.
    CoinRange coins; // Range of coins associated with this deposit.
  }

  // `depositId` is used as a counter (Starting from 0) for generating deposit-ids.
  uint256 public depositId;
  mapping(uint256 => Deposit) public deposits;

  uint256 public coinsDeposited; // Number of coins deposited.

  //------------------------------------------------------------------

  struct Exit {
    uint256 blockIndex; // Index of the block the exiting transaction exists.
    address exitor; // Who made this exit.
    CoinRange coins; // Coins to exit.
    uint256 finalAt; // block.timestamp when the exit was made + CHALLENGE_TIME.
    bool invalid; // Whether this exit has been invalidated or not.
  }
  // Exit list. (Sorted by `blockIndex`)
  Exit[] public exits;

  //------------------------------------------------------------------

  // To store which coins are exited and prevent exiting them again.
  CoinRange[] public exiteds;

  // Returns if the supplied range of coins exist and are not exited.
  function coinExists(CoinRange _coins)
  public
  view
  returns (bool) {
    // Check if the coins exist.
    if(_coins.start + _coins.offset >= coinsDeposited)
      return false;

    // Check if part/all of the coins are not exited yet.
    for(uint256 i = 0; i < exiteds.length; i++)
      if(_coins.collidesWith(_exiteds[i]))
        return false;

    return true;
  }

  //------------------------------------------------------------------

  constructor() public {
    operator = msg.sender;
    depositId = 0;
    coinsDeposited = 0;

    // Let's say all deposits are stored in block 0, so they have highest
    // priority when finalizing exits.
    height = 1;
  }

  function deposit()
  public
  payable {
    require(msg.value > 0, "Deposit amount should be > 0.");
    require(msg.sender != address(0), "Invalid sender address.");

    // Reserve `msg.value` number of coins, starting from `coinsDeposited`
    deposits[depositId] = Deposit(msg.sender, CoinRange(coinsDeposited, msg.value));
    depositId = depositId.add(1);
    coinsDeposited = coinsDeposited.add(msg.value);
  }

  function submitBlock(bytes32 _root, uint256 _count, uint256 _index)
  public
  onlyOperator {
    require(height == _index, "Block index mismatch.");
    require(_count == coinsDeposited, "Coin count mismatch.");
    Block memory newBlock = Block(_root, _count, block.timestamp);
    blocks[_blockIndex] = newBlock;
    height = height.add(1);
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

    // 0 is the block index, meaning that we are creating an exit for a deposit.
    // (As we have considered all deposit transactions are stored in block 0)
    createExit(0, deposit.coins);
  }

  function exitTransaction(bytes _txBytes, bytes _proof, bytes _signature, address _spender, uint256 _targetBlock)
  public
  bonded
  payable {
    validateTransaction(_txBytes, _proof, _signature, _spender, _targetBlock);

    Transaction memory transaction = decodeTransaction(_txBytes);
    require(transaction.newOwner == msg.sender, "You are not the owner.");

    createExit(_targetBlock, transaction.coins);
  }


  function createExit(uint256 _blockIndex, CoinRange _coins)
  private {
    uint256 finalAt = block.timestamp.add(challengeTimeout);
    exits.push(Exit(_blockIndex, msg.sender, _coins, finalAt, false));
    exits.sortByBlockIndex(); // Sort after adding it to list.
  }


  function challengeExit(uint256 _exitId, bytes _txBytes, bytes _proof, bytes _signature, uint256 _targetBlock)
  public {
    Transaction memory transaction = decodeTransaction(_txBytes);

    Exit storage exit = exits[_exitId];
    require(exit.exitor != address(0), "Exit does not exist.");
    require(!exit.invalid, "Already challenged.");
    require(exit.exitor != msg.sender, "You cant challenge yourself.");

    require(exit.coins.collidesWith(transaction.coins), "Your transaction and the exit being challenged should have collision with each other.");

    // We will allow users to challenge exit even after challenge time, until someone finalize it.

    validateTransaction(_txBytes, _proof, _signature, exit.exitor, _targetBlock);

    exit.invalid = true;

    msg.sender.transfer(EXIT_BOND);
  }


  function validateTransaction(bytes _txBytes, bytes _proof, bytes _signature, address _signer, uint256 _targetBlock)
  public
  view
  returns (bool) {
    Transaction memory transaction = decodeTransaction(_txBytes);

    require(coinExists(transaction.coins), "Coins do not exist.");

    require(_targetBlock < height, "_targetBlock should be less than height.");
    for(uint256 prevBlockIndex : transaction.prevTxBlockIndex)
      require(prevBlockIndex < _targetBlock, "All prevTxBlockIndices should be less than _targetBlock.");

    bytes32 h = hashTransaction(transaction);

    require(transaction.newOwner != _signer, "Preventing sending loop.");
    require(_proof.verifyMerkleProof(blocks[_targetBlock].merkleRoot, h, transaction.coinId), "Incorrect merkle-proof.");
    require(Transaction.verifySignature(_signer, h, _signature), "Incorrect signature.");

    return true;
  }

  function finalizeExits()
  public  {
    uint256 timestamp = block.timestamp;

    for(uint256 i = 0; i < exits.length; i++) {
      Exit memory exit = exits[i];
      if(!exit.invalid && timestamp > exit.finalAt && coinExists(exit.coins)) {
        uint256 exitAmount = exit.coins.offset.add(EXIT_BOND);
        exit.exitor.transfer(exitAmount);
        exiteds.push(exit.coins); // Prevent the exited coins being exited again.
      }
    }
  }

}
