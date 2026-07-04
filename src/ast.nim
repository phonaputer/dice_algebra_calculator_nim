import std/algorithm
import std/options
import std/random
import std/strformat
import std/times
from errors import DiceError


var globalRand = initRand(getTime().toUnix)


type
  ExecutionResult* = object
    result*: int
    description*: string


type
  AST* = ref object of RootObj

method execute*(ast: AST): ExecutionResult {.base.} =
  # override this base method
  quit "to override!"


type
  IntegerAST* = ref object of AST
    intValue: int

method execute*(ast: IntegerAST): ExecutionResult =
  return ExecutionResult(result: ast.intValue, description: "")

proc newIntegerAST*(intValue: int): IntegerAST =
  return IntegerAST(intValue: intValue)


type
  ShortRollAST* = ref object of AST
    numFaces: Positive
    randGen: Rand

method execute*(ast: ShortRollAST): ExecutionResult =
  let roll = ast.randGen.rand(Positive(1)..ast.numFaces)

  return ExecutionResult(
    result: roll,
    description: &"\nRolling d{ast.numFaces}...\nYou rolled: {roll}\n"
  )

proc newShortRollAST*(numFaces: Positive,
    randGen: Rand = globalRand): ShortRollAST =
  return ShortRollAST(numFaces: numFaces, randGen: randGen)


type
  LongRollAST* = ref object of AST
    numDie: Positive
    numFaces: Positive
    keepLow: Option[Positive]
    keepHigh: Option[Positive]
    randGen: Rand

method execute*(ast: LongRollAST): ExecutionResult =
  var rolls: seq[int] = @[]
  var description = &"\nRolling {ast.numDie}d{ast.numFaces}...\n"
  var sum = 0

  for i in 1..ast.numDie:
    let roll = ast.randGen.rand(Positive(1)..ast.numFaces)
    description &= &"You rolled: {roll}\n"
    sum += roll
    rolls.add(roll)

  if ast.keepLow.isSome and ast.keepLow.get < rolls.len:
    sum = 0
    rolls.sort
    for i in 0..<ast.keepLow.get:
      sum += rolls[i]

  elif ast.keepHigh.isSome and ast.keepHigh.get < rolls.len:
    sum = 0
    rolls.sort(SortOrder.Descending)
    for i in 0..<ast.keepHigh.get:
      sum += rolls[i]

  return ExecutionResult(result: sum, description: description)

proc newLongRollAST*(
  numDie: Positive,
  numFaces: Positive,
  keepLow: Option[Positive] = none(Positive),
  keepHigh: Option[Positive] = none(Positive),
  randGen: Rand = globalRand
): LongRollAST =
  return LongRollAST(
    numDie: numDie,
    numFaces: numFaces,
    keepLow: keepLow,
    keepHigh: keepHigh,
    randGen: randGen
  )


type
  MathOp* = enum
    add, subtract, multiply, divide

type
  MathAST* = ref object of AST
    op: MathOp
    leftOperand: AST
    rightOperand: AST

method execute*(ast: MathAST): ExecutionResult =
  let leftResult = ast.leftOperand.execute
  let rightResult = ast.rightOperand.execute

  result = ExecutionResult(
    result: 0,
    description: leftResult.description & rightResult.description
  )

  case ast.op
  of MathOp.add:
    result.result = leftResult.result + rightResult.result
  of MathOp.subtract:
    result.result = leftResult.result - rightResult.result
  of MathOp.multiply:
    result.result = leftResult.result * rightResult.result
  of MathOp.divide:
    if rightResult.result == 0:
      raise newException(DiceError, "Division by zero is not allowed.")
    result.result = leftResult.result div rightResult.result

  return result

proc newMathAST*(op: MathOp, leftOperand: AST, rightOperand: AST): MathAST =
  return MathAST(op: op, leftOperand: leftOperand, rightOperand: rightOperand)
