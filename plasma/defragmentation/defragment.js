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
  const fromBalance = balances[from]
  const fromRanges = fromBalance.ownedRange
  const toBalance = balances[to]
  const toRanges = toBalance.ownedRange

  if (fromBalance.size > amount) { // Check if from has enough balance before persuing
    const adjacent = areAdjacent(fromRanges, toRanges)

    if (adjacent) {
      // TODO: if adjacent atomic swap after transfer.
    } else {
      if (fromRanges[0] === toRanges[1]) {
        fromRanges[0] = fromRanges[0] + amount
        toRanges[1] = toRanges[1] + amount
      } else {
        fromRanges[1] = fromRanges[1] - amount
        toRanges[0] = toRanges[0] - amount
      }
      balances[from] = fromBalance
      balances[to] = toBalance
      
      console.log("balances: ", balances)
      console.log("ranges: ", ranges)
    }
  }
}

const areAdjacent = (itemOne, itemTwo) => {
  if (itemOne[0] === itemTwo[1] || itemOne[1] === itemTwo[0]) {
    return false 
  } else{
    return true
  }
}

transfer("0x0", "0x1", 1)