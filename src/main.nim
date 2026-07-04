import std/strformat
import std/os
import ast
import lexer
import parser

when isMainModule:
  try:
    stdout.write "Please enter a dice algebra expression: "

    let result = parse(tokenize(readLine(stdin))).execute

    if paramCount() > 0 and paramStr(1) == "--v":
      stdout.write(result.description)

    echo &"\nYour result is: {result.result}"

  except Exception as e:
    echo &"Error: {e.msg}"
