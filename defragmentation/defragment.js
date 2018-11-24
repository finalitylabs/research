const ranges = [[0, 2], [3, 5], [6, 10]]; // TODO: This should be done in a sum or sparce tree

const balances = {
  "0x0": {
    ownedRange: ranges[0],
    size: (ranges[0][1] - ranges[0][0] + 1), // 0 counts as a coin so add 1
  },
  "0x1": {
    ownedRange: ranges[1],
    size: (ranges[1][1] - ranges[1][0] + 1),
  },
  "0x2": {
    ownedRange: ranges[2],
    size: (ranges[2][1] - ranges[2][0] + 1),
  },
}


const transfer = (from, to, amount) => {
  from = balances[from]
  to = balances[to]
  const adjacent = areAdjacent(from.ownedRange, to.ownedRange)

  if (from.size > amount) { // Check if from has enough balance before persuing
    if (adjacent) {
      // TODO: if adjacent atomic swap after transfer.
    } else {
      // TODO: if no adjacent decide what side of the owned coins needs to be tranfered.
    }
  }
}

const areAdjacent = (itemOne, itemTwo) => {
  if (itemOne[0] < itemTwo[1]) {
    return itemTwo[0] - 1  === itemOne[1] ? false : true
  } else {
    return itemOne[0] - 1 === itemTwo[1] ? false : true
  }
}