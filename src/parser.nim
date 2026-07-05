import std/options
import ast
import iterators
import tokens
from errors import DiceError


proc validateHaveTokens(tokens: seq[Token]) =
  if tokens.len < 1:
    raise newException(DiceError, "Empty input.")

proc validateParenBalance(tokens: seq[Token]) =
  var openCloseBalance = 0

  for token in tokens:
    if token.kind == TokenKind.openParenthesis:
      openCloseBalance += 1
    elif token.kind == TokenKind.closeParenthesis:
      openCloseBalance -= 1

    if openCloseBalance < 0:
      break

  if openCloseBalance != 0:
    raise newException(DiceError, "Expression contains an unclosed parenthetical.")

proc parseIntRaw(tokens: var Iterator[Token]): Positive =
  let nextToken = tokens.next
  if nextToken.isNone or nextToken.get.kind != TokenKind.integer:
    raise newException(DiceError, "Input expression is not valid.")

  return nextToken.get.intValue

proc parseInt(tokens: var Iterator[Token]): AST =
  return newIntegerAST(intValue = parseIntRaw(tokens))

proc parseShortRoll(tokens: var Iterator[Token]): AST =
  let nextToken = tokens.next
  if nextToken.isNone or nextToken.get.kind != TokenKind.dice:
    raise newException(DiceError, "Parse shortroll should not be called when the next token is not D.")

  return newShortRollAST(numFaces = parseIntRaw(tokens))

proc parseLongRoll(tokens: var Iterator[Token]): AST =
  let numDie = parseIntRaw(tokens)

  let nextToken = tokens.next
  if nextToken.isNone or nextToken.get.kind != TokenKind.dice:
    raise newException(DiceError, "Parse longroll should not be called when the 2nd token is not D.")

  let numFaces = parseIntRaw(tokens)

  var keepLow, keepHigh: Option[Positive]
  let peekToken = tokens.peek
  if peekToken.isSome and peekToken.get.kind == TokenKind.keepLow:
    discard tokens.next # Discard 'l' token
    keepLow = some(parseIntRaw(tokens))
  elif peekToken.isSome and peekToken.get.kind == TokenKind.keepHigh:
    discard tokens.next # Discard 'h' token
    keepHigh = some(parseIntRaw(tokens))

  return newLongRollAST(
    numDie = numDie,
    numFaces = numFaces,
    keepLow = keepLow,
    keepHigh = keepHigh
  )

proc parseRoll(tokens: var Iterator[Token]): AST =
  let peek = tokens.peek
  if peek.isNone:
    raise newException(DiceError, "Input expression is not valid.")

  if peek.get.kind == TokenKind.dice:
    return parseShortRoll(tokens)

  let peekNext = tokens.peekNext
  if peekNext.isSome and peekNext.get.kind == TokenKind.dice:
    return parseLongRoll(tokens)

  return parseInt(tokens)

proc parseAdd(tokens: var Iterator[Token]): AST

proc parseAtom(tokens: var Iterator[Token]): AST =
  let peek = tokens.peek
  if peek.isNone:
    raise newException(DiceError, "Input expression is not valid.")

  if peek.get.kind != TokenKind.openParenthesis:
    return parseRoll(tokens)

  discard tokens.next # Discard '('
  result = parseAdd(tokens)
  discard tokens.next # Discard ')'

  return result

proc parseMult(tokens: var Iterator[Token]): AST =
  result = parseAtom(tokens)

  var peek = tokens.peek
  while peek.isSome:
    let op = case peek.get.kind
      of TokenKind.multiply:
        MathOp.multiply
      of TokenKind.divide:
        MathOp.divide
      of TokenKind.add, TokenKind.subtract, TokenKind.closeParenthesis:
        return result
      else:
        raise newException(DiceError, "Input expression is not valid.")

    discard tokens.next # Discard '*' or '/'

    result = newMathAST(op = op, leftOperand = result, rightOperand = parseAtom(tokens))

    peek = tokens.peek

  return result

proc parseAdd(tokens: var Iterator[Token]): AST =
  result = parseMult(tokens)

  var peek = tokens.peek
  while peek.isSome:
    let op = case peek.get.kind
      of TokenKind.add:
        MathOp.add
      of TokenKind.subtract:
        MathOp.subtract
      of TokenKind.closeParenthesis:
        return result
      else:
        raise newException(DiceError, "Input expression is not valid.")

    discard tokens.next # Discard '+' or '-'

    result = newMathAST(op = op, leftOperand = result, rightOperand = parseMult(tokens))

    peek = tokens.peek

  return result

proc parse*(tokens: seq[Token]): AST =
  validateHaveTokens(tokens)
  validateParenBalance(tokens)

  var tokenIterator = newIterator(tokens)

  return parseAdd(tokenIterator)
