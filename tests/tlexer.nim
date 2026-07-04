import unittest
import lexer
import tokens
from errors import DiceError


suite "tokenize":

  test "valid runes input, returns as tokens":
    let input = "1d2D3l4L5h6H7+8-9*/100()"

    let results = tokenize(input)

    let expected: seq[Token] = @[
      Token(kind: TokenKind.integer, intValue: 1),
      Token(kind: TokenKind.dice),
      Token(kind: TokenKind.integer, intValue: 2),
      Token(kind: TokenKind.dice),
      Token(kind: TokenKind.integer, intValue: 3),
      Token(kind: TokenKind.keepLow),
      Token(kind: TokenKind.integer, intValue: 4),
      Token(kind: TokenKind.keepLow),
      Token(kind: TokenKind.integer, intValue: 5),
      Token(kind: TokenKind.keepHigh),
      Token(kind: TokenKind.integer, intValue: 6),
      Token(kind: TokenKind.keepHigh),
      Token(kind: TokenKind.integer, intValue: 7),
      Token(kind: TokenKind.add),
      Token(kind: TokenKind.integer, intValue: 8),
      Token(kind: TokenKind.subtract),
      Token(kind: TokenKind.integer, intValue: 9),
      Token(kind: TokenKind.multiply),
      Token(kind: TokenKind.divide),
      Token(kind: TokenKind.integer, intValue: 100),
      Token(kind: TokenKind.openParenthesis),
      Token(kind: TokenKind.closeParenthesis)
    ]
    check expected == results

  test "valid runes and whitespace input, returns as tokens ignoring whitespace":
    let input = "1 d 2 D    3\t  \n  l 4 L 5 h  6 　　　H 7 \t\t+ 8 - 9 * / 1 \t\n 00 ( ) "

    let results = tokenize(input)

    let expected: seq[Token] = @[
      Token(kind: TokenKind.integer, intValue: 1),
      Token(kind: TokenKind.dice),
      Token(kind: TokenKind.integer, intValue: 2),
      Token(kind: TokenKind.dice),
      Token(kind: TokenKind.integer, intValue: 3),
      Token(kind: TokenKind.keepLow),
      Token(kind: TokenKind.integer, intValue: 4),
      Token(kind: TokenKind.keepLow),
      Token(kind: TokenKind.integer, intValue: 5),
      Token(kind: TokenKind.keepHigh),
      Token(kind: TokenKind.integer, intValue: 6),
      Token(kind: TokenKind.keepHigh),
      Token(kind: TokenKind.integer, intValue: 7),
      Token(kind: TokenKind.add),
      Token(kind: TokenKind.integer, intValue: 8),
      Token(kind: TokenKind.subtract),
      Token(kind: TokenKind.integer, intValue: 9),
      Token(kind: TokenKind.multiply),
      Token(kind: TokenKind.divide),
      Token(kind: TokenKind.integer, intValue: 100),
      Token(kind: TokenKind.openParenthesis),
      Token(kind: TokenKind.closeParenthesis)
    ]
    check expected == results

  test "unexpected character input, raises DiceError":
    let input = "123 WHAT?!"
    var gotDiceError = false

    try:
      discard tokenize(input)

    except DiceError as e:
      gotDiceError = true
      check "Unexpected character in input: 'W'" == e.msg

    check gotDiceError == true
