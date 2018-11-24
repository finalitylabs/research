// TODO: Ranges should be done in a sum or sparce tree
const ranges = [[0, 3], [3, 6], [6, 9]]; 

const balances = {
  "0x0": {
    ownedRange: ranges[0],
    size: (ranges[0][1] - ranges[0][0]),
  },
  "0x1": {
    ownedRange: ranges[1],
    size: (ranges[1][1] - ranges[1][0]),
  },
  "0x2": {
    ownedRange: ranges[2],
    size: (ranges[2][1] - ranges[2][0]),
  },
}


const transfer = (from, to, amount) => {
  from = balances[from]
  to = balances[to]
  if (from.size > amount) { // Check if from has enough balance before persuing
    const adjacent = areAdjacent(from.ownedRange, to.ownedRange)
    
    if (adjacent) {
      // TODO: if adjacent atomic swap after transfer.
    } else {
      // TODO: if not adjacent decide what side of the owned coins needs to be tranfered.

    }
  }
}

const areAdjacent = (itemOne, itemTwo) => {
  if (itemOne[0] < itemTwo[1]) {
    return itemTwo[0] === itemOne[1] ? false : true
  } else {
    return itemOne[0] === itemTwo[1] ? false : true
  }
}