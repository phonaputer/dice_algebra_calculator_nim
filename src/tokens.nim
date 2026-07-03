from system import Natural


type TokenKind* = enum
  dice, keepLow, keepHigh, add, subtract, multiply, divide, openParenthesis,
    closeParenthesis, integer


type Token* = object
  kind*: Token_Kind
  intValue*: Natural
