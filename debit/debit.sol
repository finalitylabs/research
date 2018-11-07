pragma solidity 0.4.24;

contract PlasmaDebit {

  address public operator;

  struct Transaction {
    uint256 srcChannelId;
    uint256 dstChannelId;
    uint256 srcPrevTxBlockIndex;
    uint256 dstPrevTxBlockIndex;
    uint256 srcNewBalance;
    uint256 dstNewBalance;
  }

  struct Block {
    bytes32 merkleRoot;
    uint256 timestamp;
  }

  struct Exit {
    uint256 finalAt; // block.timestamp when the exit was made + CHALLENGE_TIME.
    uint256 amount; // Exiting amount.
    bool invalid;
  }

  struct Channel {
    address owner; // Initial owner of the channel. (Doesn't change)
    uint256 amount; // Initial balance of the channel. (Doesn't change)
    uint256 capacity; // Initial capacity of the channel. (Operator can increase this)
  }

  // Number of blocks submitted.
  uint256 public height;
  mapping(uint256 => Block) public blocks;

  // `channelId` is used as a counter (Starting from 0) for generating channel-ids.
  uint256 public channelId;
  mapping(uint256 => Channel) public channels;

  // Exit matrix.
  // Mapping (channel-id, block-index) to its corresponsing Exit.
  mapping(uint256 => mapping(uint256 => Exit)) public exits;

  // Because of the Solidity's limitation of iterating on maps, we should store
  // occupied indices of each row of the exit matrix elsewhere (Sorted).
  // Traversing over all Exits of a channel:
  //
  // for(uint256 i = 0; i < exitQueue[id].length; i++) {
  //   Exit memory exit = exits[exitQueue[id][i]]
  // }
  mapping(uint256 => uint256[]) public exitQueue;

  constructor() public {
    operator = msg.sender;
    channelId = 0;

    // Let's say all deposits are stored in block 0, so they have highest
    // priority when finalizing exits.
    height = 1;
  }

  function deposit()
  public
  payable {
    require(msg.value > 0, "Deposit amount should be > 0.");
    require(msg.sender != address(0), "Invalid sender address.");

    // Amount & Capacity are equal when you create a Channel, then the operator
    // add liquidity by extending the capacity. (See `extendCapacity`)
    channels[channelId] = Channel(msg.sender, msg.value, msg.value);
    channelId = channelId.add(1);
  }

  function submitBlock(bytes32 _merkleRoot, uint256 _blockIndex)
  public
  onlyOperator {
    require(height == _blockIndex, "blockIndex mismatch.");
    Block memory newBlock = Block(_merkleRoot, block.timestamp);
    blocks[_blockIndex] = newBlock;
    height = height.add(1);
  }

  function extendCapacity(uint256 _channelId)
  public
  payable
  onlyOperator {
    Channel storage channel = channels[_channelId];
    require(channel.capacity > 0, "Channel does not exist.");
    require(msg.value > 0, "msg.value should be > 0.");
    channel.capacity += msg.value;
  }

  modifier bonded() {
    require(msg.value == EXIT_BOND);
    _;
  }

  // Use this function if you want to exit a deposit transaction.
  function exitChannel(uint256 _channelId)
  public
  bonded
  payable {
    require(exits[_channelId][0].finalAt == 0, "Exit exists.");
    Channel storage channel = channels[_channelId];
    require(channel.owner == msg.sender, "You are not the owner.");

    // 0 is the block index, meaning that we are creating an exit for a deposit.
    // (As we have considered all deposit transactions are stored in block 0)
    createExit(_channelId, 0, channel.amount);
  }

  function exitTransaction(bytes _txBytes, bytes _srcProof, bytes _dstProof, address _src, bytes _srcSignature, address _dst, bytes _dstSignature, uint256 _targetBlock, bool _isDst)
  public
  bonded
  payable {
    Transaction memory transaction = decodeTransaction(_txBytes);

    validateTransaction(_txBytes, _srcProof, _dstProof, _src, _srcSignature, _dst, _dstSignature, _targetBlock);

    uint256 exitingChannelId = transaction.srcChannelId;
    uint256 exitingAmount = transaction.srcNewBalance;
    address owner = _src;
    if(isDst) {
      exitingChannelId = transaction.dstChannelId;
      exitingAmount = transaction.dstNewBalance;
      owner = _dst;
    }

    require(exits[exitingChannelId][_targetBlock].finalAt == 0, "Exit exists.");

    Channel storage channel = channels[exitingChannelId];
    require(channel.capacity > 0, "Channel does not exist.");
    require(owner == msg.sender, "You are not the owner.");

    createExit(exitingChannelId, _targetBlock, exitingAmount);
  }


  function createExit(uint256 _channelId, uint256 _blockIndex, uint256 _amount)
  private {
    uint256 finalAt = block.timestamp.add(challengeTimeout);
    exits[_channelId][_blockIndex] = Exit(finalAt, false, _amount);
    exitQueue[_channelId].push(_blockIndex);
    exitQueue[_channelId].sort(); // Sort after adding it to list.
  }


  function challengeExit(bytes _txBytes, bytes _proofSrc, bytes _proofDst, address _src, bytes _srcSignature, address _dst, bytes _dstSignature, uint256 _targetBlock, bool isDst)
  public {

    Transaction memory transaction = decodeTransaction(_txBytes);

    require(channels[transaction.srcChannelId].amount > 0, "Channel does not exist.");

    uint256 prevTxBlockIndex = transaction.srcPrevTxBlockIndex;
    if(isDst)
      prevTxBlockIndex = transaction.dstPrevTxBlockIndex;

    Exit storage exit = exits[transaction.channelId][prevTxBlockIndex];
    require(exit.finalAt != 0, "Exit does not exist.");
    require(!exit.invalid, "Already challenged.");

    // We will allow users to challenge exit even after challenge time, until someone finalize it.

    validateTransaction(_txBytes, _srcProof, _dstProof, _src, _srcSignature, _dst, _dstSignature, _targetBlock);

    exit.invalid = true;

    msg.sender.transfer(exitBond);
  }


  function validateTransaction(bytes _txBytes, bytes _srcProof, bytes _dstProof, address _src, bytes _srcSignature, address _dst, bytes _dstSignature, uint256 _targetBlock)
  public
  view
  returns (bool) {
    Transaction memory transaction = decodeTransaction(_txBytes);
    Channel storage srcChannel = channels[transaction.srcChannelId];
    Channel storage dstChannel = channels[transaction.dstChannelId];

    require(_targetBlock < height, "_targetBlock should be less than height.");
    require(transaction.srcPrevTxBlockIndex < _targetBlock, "srcPrevTxBlockIndex should be less than _targetBlock.");
    require(transaction.dstPrevTxBlockIndex < _targetBlock, "dstPrevTxBlockIndex should be less than _targetBlock.");

    require(transaction.srcNewBalance <= srcChannel.capacity, "Source channel balance higher than capacity.");
    require(transaction.dstNewBalance <= dstChannel.capacity, "Destination channel balance hight than capacity.");

    bytes32 h = hashTransaction(transaction);

    require(_srcProof.verifyMerkleProof(blocks[_targetBlock].merkleRoot, h, transaction.srcChannelId), "Incorrect merkle-proof for source.");
    require(_dstProof.verifyMerkleProof(blocks[_targetBlock].merkleRoot, h, transaction.dstChannelId), "Incorrect merkle-proof for destination.");

    require(Transaction.verifySignature(_src, h, _srcSignature), "Incorrect signature for source.");
    require(Transaction.verifySignature(_dst, h, _dstSignature), "Incorrect signature for destination.");

    return true;
  }

  function finalizeExits(uint256 _channelId)
  public  {
    uint256 timestamp = block.timestamp;

    Channel storage channel = channels[_channelId];
    require(channel.amount > 0, "Channel does not exist.");

    // true if a valid exit is found.
    bool finalized = false;

    while (exitQueue[_channelId].length > 0) {
       // Pop first item.
      uint256 index = exitQueue[_channelId].pop();

      Exit memory exit = exits[_channelId][index];
      if (!exit.invalid && !finalized) {
        uint256 exitAmount = amount.add(exitBond);

        channel.owner.transfer(exitAmount);
        operator.transfer(channel.capacity.sub(amount))

        delete channels[_channelId];
        finalized = true;
      }
      delete exits[_channelId][index];
    }
  }
}
