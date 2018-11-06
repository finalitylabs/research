pragma solidity 0.4.24;

contract PlasmaCash {

  address public operator;

  struct Transaction {
    uint256 coinId;
    uint256 prevTxBlockIndex;
    address newOwner;
  }

  struct Block {
    bytes32 merkleRoot;
    uint256 timestamp;
  }

  struct Exit {
    address exitor;
    uint256 finalAt; // block.timestamp when the exit was made + CHALLENGE_TIME.
    bool invalid;
  }

  struct Coin {
    address owner; // Initial owner of that coin, doesn't change.
    uint256 amount;
  }

  // Number of blocks submitted.
  uint256 public height;
  mapping(uint256 => Block) public blocks;

  // `coinId` is used as a counter (Starting from 0) for generating coin-ids.
  uint256 public coinId;
  mapping(uint256 => Coin) public coins;

  // Exit matrix.
  // Mapping (coin-id, block-index) to its corresponsing Exit.
  mapping(uint256 => mapping(uint256 => Exit)) public exits;

  // Because of the Solidity's limitation of iterating on maps, we should store
  // occupied indices of each row of the exit matrix elsewhere (Sorted).
  // Traversing over all Exits of a coin:
  //
  // for(uint256 i = 0; i < exitQueue[id].length; i++) {
  //   Exit memory exit = exits[exitQueue[id][i]]
  // }
  mapping(uint256 => uint256[]) public exitQueue;

  constructor() public {
    operator = msg.sender;
    coinId = 0;

    // Let's say all deposits are stored in block 0, so they have highest
    // priority when finalizing exits.
    height = 1;
  }

  function deposit()
  public
  payable {
    require(msg.value > 0, "Deposit amount should be > 0.");
    require(msg.sender != address(0), "Invalid sender address.");
    coins[coidInd] = Coin(msg.sender, msg.value);
    coinId = nonce.add(1);
  }

  function submitBlock(bytes32 _merkleRoot, uint256 _blockIndex)
  public
  onlyOperator {
    require(height == _blockIndex, "blockIndex mismatch.");
    Block memory newBlock = Block(_merkleRoot, block.timestamp);
    blocks[_blockIndex] = newBlock;
    height = height.add(1);
  }

  modifier bonded() {
    require(msg.value == EXIT_BOND);
    _;
  }

  // Use this function if you want to exit a deposit transaction.
  function exitCoin(uint256 _coinId)
  public
  bonded
  payable {
    require(exits[_coinId][0].finalAt == 0, "Exit exists.");
    Coin storage coin = coins[_coinId];
    require(coin.owner == msg.sender, "You are not the owner.");

    // 0 is the block index, meaning that we are creating an exit for a deposit.
    // (As we have considered all deposit transactions are stored in block 0)
    createExit(_coinId, 0);
  }

  function exitTransaction(bytes _txBytes, bytes _proof, bytes _signature, address _spender, uint256 _targetBlock)
  public
  bonded
  payable {
    validateTransaction(_txBytes, _proof, _signature, _spender, _targetBlock);

    require(exits[transaction.coinId][_targetBlock].finalAt == 0, "Exit exists.");

    Coin storage coin = coins[transaction.coinId];
    require(coin.amount > 0, "Coin does not exist.");
    require(transaction.newOwner == msg.sender, "You are not the owner.");

    createExit(transaction.coinId, _targetBlock);
  }


  function createExit(uint256 _coinId, uint256 _blockIndex)
  private {
    uint256 finalAt = block.timestamp.add(challengeTimeout);
    exits[_coinId][_blockIndex] = Exit(msg.sender, finalAt, false);
    exitQueue[_coinId].push(_blockIndex);
    exitQueue[_coinId].sort(); // Sort after adding it to list.
  }


  function challengeExit(bytes _txBytes, bytes _proof, bytes _signature, uint256 _targetBlock)
  public {

    Transaction memory tx = decodeTransaction(_txBytes);

    require(coins[transaction.coinId].amount > 0, "Coin does not exist.");

    Exit storage exit = exits[transaction.coinId][transaction.prevTxBlockIndex];
    require(exit.exitor != address(0), "Exit does not exist.");
    require(!exit.invalid, "Already challenged.");
    require(exit.exitor != msg.sender, "You cant challenge yourself.");

    // We will allow users to challenge exit even after challenge time, until someone finalize it.

    validateTransaction(_txBytes, _proof, _signature, exit.exitor, _targetBlock);

    exit.invalid = true;

    msg.sender.transfer(exitBond);
  }


  function validateTransaction(bytes _txBytes, bytes _proof, bytes _signature, address _signer, uint256 _targetBlock)
  public
  view
  returns (bool) {
    Transaction memory transaction = decodeTransaction(_txBytes);
    require(_targetBlock < height, "_targetBlock should be less than height.");
    require(transaction.prevTxBlockIndex < _targetBlock, "prevTxBlockIndex should be less than _targetBlock.");

    bytes32 h = hashTransaction(transaction);

    require(transaction.newOwner != _signer, "Preventing sending loop.");
    require(_proof.verifyMerkleProof(blocks[_targetBlock].merkleRoot, h, transaction.coinId), "Incorrect merkle-proof.");
    require(Transaction.verifySignature(_signer, h, _signature), "Incorrect signature.");

    return true;
  }

  function finalizeExits(uint256 _coinId)
  public  {
    uint256 timestamp = block.timestamp;

    Coin storage coin = coins[_coinId];
    require(coin.amount > 0, "Coin does not exist.");

    // true if a valid exit is found.
    bool finalized = false;

    while (exitQueue[_coinId].length > 0) {
       // Pop first item.
      uint256 index = exitQueue[_coinId].pop();

      Exit memory exit = exits[_coinId][index];
      if (!exit.invalid && !finalized) {
        uint256 exitAmount = amount.add(exitBond);
        exit.exitor.transfer(exitAmount);
        delete coins[_coinId];
        finalized = true;
        break;
      }
      delete exits[_coinId][index];
    }
  }
}
