from lexer import tokenize

stdout.write "Please enter a dice algebra expression: "

let user_input = readLine(stdin)

echo "You rolled: ", user_input

let tokens = tokenize(user_input)

for token in tokens:
  echo repr(token)
