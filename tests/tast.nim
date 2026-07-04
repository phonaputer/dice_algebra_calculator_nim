import std/random
import std/options
import unittest
import ast
from errors import DiceError


suite "IntegerAST":

  test "execute, should return the int":
    let ast = newIntegerAST(intValue = 5)

    let result = ast.execute

    check result.result == 5
    check result.description == ""


suite "MathAST":

  test "execute add op, should add left and right":
    let left = newIntegerAST(intValue = 5)
    let right = newIntegerAST(intValue = 2)
    let ast = newMathAST(op = MathOp.add, leftOperand = left,
        rightOperand = right)

    let result = ast.execute

    check result.result == 7
    check result.description == ""

  test "execute subtract op, should subtract right from left":
    let left = newIntegerAST(intValue = 5)
    let right = newIntegerAST(intValue = 2)
    let ast = newMathAST(op = MathOp.subtract, leftOperand = left,
        rightOperand = right)

    let result = ast.execute

    check result.result == 3
    check result.description == ""

  test "execute multiply op, should multiply left with right":
    let left = newIntegerAST(intValue = 5)
    let right = newIntegerAST(intValue = 2)
    let ast = newMathAST(op = MathOp.multiply, leftOperand = left,
        rightOperand = right)

    let result = ast.execute

    check result.result == 10
    check result.description == ""

  test "execute divide op, should integer divide left from right":
    let left = newIntegerAST(intValue = 5)
    let right = newIntegerAST(intValue = 2)
    let ast = newMathAST(op = MathOp.divide, leftOperand = left,
        rightOperand = right)

    let result = ast.execute

    check result.result == 2
    check result.description == ""

  test "execute divide op when right is zero, should raise division by zero error":
    let left = newIntegerAST(intValue = 5)
    let right = newIntegerAST(intValue = 0)
    let ast = newMathAST(op = MathOp.divide, leftOperand = left,
        rightOperand = right)

    var gotDiceError = false

    try:
      discard ast.execute

    except DiceError as e:
      gotDiceError = true
      check "Division by zero is not allowed." == e.msg

    check gotDiceError == true

  test "execute should combine and left right descriptions":
    var randGen = initRand(123)
    let left = newShortRollAST(numFaces = 5, randGen = randGen)
    let right = newShortRollAST(numFaces = 10, randGen = randGen)
    let ast = newMathAST(
      op = MathOp.add,
      leftOperand = left,
      rightOperand = right
    )

    let result = ast.execute

    check result.result == 7
    check result.description == "\nRolling d5...\nYou rolled: 1\n\nRolling d10...\nYou rolled: 6\n"


suite "ShortRollAST":

  test "execute should return random roll of numFaces":
    var randGen = initRand(123)
    let ast = newShortRollAST(numFaces = 10, randGen = randGen)

    let result = ast.execute

    check result.result == 6
    check result.description == "\nRolling d10...\nYou rolled: 6\n"


suite "LongRollAST":

  test "execute, returns sum of numDie random rolls of numFaces":
    var randGen = initRand(123)
    let ast = newLongRollAST(numDie = 3, numFaces = 10, randGen = randGen)

    let result = ast.execute

    check result.result == 16
    check result.description == "\nRolling 3d10...\nYou rolled: 6\nYou rolled: 7\nYou rolled: 3\n"

  test "execute with keepLow, returns sum of the keepLow lowest rolls":
    var randGen = initRand(123)
    let ast = newLongRollAST(
      numDie = 3,
      numFaces = 10,
      randGen = randGen,
      keepLow = some(Positive(2))
    )

    let result = ast.execute

    check result.result == 9
    check result.description == "\nRolling 3d10...\nYou rolled: 6\nYou rolled: 7\nYou rolled: 3\n"

  test "execute with keepHigh, returns sum of the keepHigh highest rolls":
    var randGen = initRand(123)
    let ast = newLongRollAST(
      numDie = 3,
      numFaces = 10,
      randGen = randGen,
      keepHigh = some(Positive(2))
    )

    let result = ast.execute

    check result.result == 13
    check result.description == "\nRolling 3d10...\nYou rolled: 6\nYou rolled: 7\nYou rolled: 3\n"

  test "execute with keepHigh & keepLow, returns sum of the keepLow lowest rolls":
    var randGen = initRand(123)
    let ast = newLongRollAST(
      numDie = 3,
      numFaces = 10,
      randGen = randGen,
      keepLow = some(Positive(2)),
      keepHigh = some(Positive(2))
    )

    let result = ast.execute

    check result.result == 9
    check result.description == "\nRolling 3d10...\nYou rolled: 6\nYou rolled: 7\nYou rolled: 3\n"
