import tokens
import ast
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

proc parse*(tokens: seq[Token]): AST =
  validateHaveTokens(tokens)
  validateParenBalance(tokens)

  return newShortRollAST(numFaces = 100)
