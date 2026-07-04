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

  return newIntegerAST(intValue = parseIntRaw(tokens))

proc parse*(tokens: seq[Token]): AST =
  validateHaveTokens(tokens)
  validateParenBalance(tokens)

  return newShortRollAST(numFaces = 100)
