type
  TokenKind* = enum
    dice, keepLow, keepHigh, add, subtract, multiply, divide, openParenthesis,
      closeParenthesis, integer

type
  Token* = object
    kind*: TokenKind
    intValue*: Natural
