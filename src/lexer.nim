from tokens import Token, Token_Kind
from errors import DiceError
import std/unicode
import std/strutils
import std/strformat


template rn(str: string): Rune =
  const res = runeAt(str, 0)
  res


proc finishInt(tokens: var seq[Token], ongoingInt: var string) =
  if ongoingInt.runeLen > 0:
    tokens.add(Token(kind: TokenKind.integer, intValue: parseInt(ongoingInt)))
    ongoingInt = ""

proc addTokenAndFinishInt(tokens: var seq[Token], ongoingInt: var string,
    tokenKind: TokenKind) =
  finishInt(tokens, ongoingInt)
  tokens.add(Token(kind: tokenKind))

proc tokenize*(userInput: string): seq[Token] =
  var ongoingInt = ""
  var tokens: seq[Token] = @[]

  for character in runes(userInput):
    case character
    of rn"d", rn"D":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.dice)
    of rn"h", rn"H":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.keepHigh)
    of rn"l", rn"L":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.keepLow)
    of rn"+":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.add)
    of rn"-":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.subtract)
    of rn"*":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.multiply)
    of rn"/":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.divide)
    of rn"(":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.openParenthesis)
    of rn")":
      addTokenAndFinishInt(tokens, ongoingInt, TokenKind.closeParenthesis)
    of rn"0", rn"1", rn"2", rn"3", rn"4", rn"5", rn"6", rn"7", rn"8", rn"9":
      ongoing_int.add(character)
    of rn" ", rn "\n", rn "\t", rn"　":
      discard # ignore whitespace
    else:
      raise newException(DiceError, &"Unexpected character in input: '{character}'")

  finishInt(tokens, ongoingInt)

  return tokens

