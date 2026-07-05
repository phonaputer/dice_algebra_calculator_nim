# Dice Algebra Calculator - Written in Nim

A dice algebra expression lexer, parser, & executor written in Nim.

The purpose of writing this application is to have fun trying out Nim by writing a simple application.
A dice algebra calculator (including lexing, parsing, and execution of string expressions) was selected as something that is probably complex enough to be interesting yet is simple enough to do in an afternoon.

It's also something that can be extended later if that seems like it would be fun (e.g. this application could run a GUI window in which expressions can be input & a breakdown of the results can be shown, etc.).

And finally this is a project which can be done in any language, which allows comparing and constrasting (also fun).

The goal here is to write a program with source code which is as clean as possible (not an easy task without an old hand to ask questions to) and learn about tooling around the language.

## What is "Dice Algebra?"

Dice algebra consists of simple mathematical expressions where operands may be a "dice roll."

A simple dice roll takes the format `xdy` (or `xDy`) where both `x` and `y` must be integers.
`xdy` means that a `y`-sided die will be rolled `x` times. For example, `3d6` will roll a 6-sided die three times and sum the results.

The leading `x` may be omitted if it is 1. For example, `d4` rolls a 4-sided die one time.

When rolling more than one die it is possible to keep only the lowest `n` rolls or the highest `n` rolls by appending `ln` or `hn`, respectively, to the roll. For example, `2d20h1` will roll two 20-sided dice and keep the highest result.

In addition to rolling dice, it is possible to include integers, addition `+`, subtraction `-`, multiplcation `*`, integer division `/`, and parenthetical expressions `(...)`. For example, `(2d6 + 5) * 10` will roll two 6-sided die, add five to that result, then mutiply that result by ten.

All integers must be positive (or 0).

## ANTLR Grammar

The above dice algebra format can be expressed as the following ANTLR 4 grammar. This grammar is more-or-less what this application targets when parsing input.

```ANTLR
grammar DiceAlgebra;

// Parser

add : mult (('+' | '-') mult)* ;
mult : atom (('*' | '/') atom)* ;
atom : (roll | '(' add ')') ;
roll : (integer | longroll | shortroll) ;
longroll : integer D integer ((H integer | L integer))? ;
shortroll : D integer ;
integer : NUMBER ;

// Lexer

WHITESPACE : ' ' -> skip ;
NUMBER : [0-9]+ ;
D : 'd' | 'D' ;
PLUS : '+' ;
MINUS : '-' ;
MULT: '*' ;
DIV : '/' ;
OPENPAREN : '(' ;
CLOSEPAREN : ')' ;
H : 'h' | 'H' ;
L: 'l' | 'L' ;
```

## How to Run

The dice algebra calculator compiles to a CLI application binary.
When the CLI is executed, it prompts the user for a dice algebra expression.
Then it computes the expression and prints the result.

An example invocation looks like:

```
> ./dice_algebra_calculator
Please enter a dice algebra expression: 2d6 + 10

Your result is: 14
```

The binary may be invoked with the `--v` flag for verbose output (which prints all dice rolls):

```
> ./dice_algebra_calculator --v
Please enter a dice algebra expression: 2d6 + 10

Rolling 2d6...
You rolled: 3
You rolled: 1

Your result is: 14
```

## How to Build Locally

To compile, run the following `make` command from the root directory of this repository.

```bash
make compile
```

This will create a `dice_algebra_calculator` executable in the repository root.

## How to Run the Unit Tests Locally

To run the unit tests, run the following `make` command from the root directory of this repository.

```bash
make test
```

Please note that this requires having [Nimble](https://github.com/nim-lang/nimble) installed.
For me, this was included in the tarball I downloaded from [the Nim website](https://nim-lang.org/install.html) when installing the language.

## Retrospective Thoughts

Nim is a bit different from the other languages I've tried so far.
Despite billing itself as a systems programming language, it is in fact garbage collected (though, interestingly, with the option to disable GC).
Nim's GC claims to target the same level of performance as C/C++/Rust/etc. by using an automatic reference/cycle counting strategy
that doesn't require GC pauses and should, in theory, lead to a deterministic, low-latency GC running time.
This strikes me as quite similar to C++'s `std::shared_ptr`, except Nim does it for you.
Nim also provides [an analog](https://nim-lang.org/docs/isolation.html) of `std::unique_ptr` in its standard library, though it is stated to be experimental.

Given the above, I wonder if Nim can truly be considered a competitor to C++ or C?
In theory it should perform similarly to "modern" C++ using smart pointers.
But if you happen upon a scenario that Nim's ARC/ORC doesn't optimize well you could be stuck.
At the end of the day, I do like Nim's GC strategy though.
Even if you're not always hitting C++ performance you'll likely be getting better performance than other GC'd langs like Java or Python while keeping that higher level syntax.

Talking about the syntax, I did find it to be highly productive and readable.
It has a number of things that I think more languages should have - including named parameters, default parameter values, and case statements as expressions.
My only gripe would be the lack of interfaces, though base classes can fill this gap (as in C++).
And I will say the templating feature was pretty darn cool.

On the negative side, my number one complaint is that apparently the languge used to be named "Nimrod" and someone decided to change it.
What gives, Nim devs?
Maybe they wanted to reserve "Nimrods" for use as their cult-style name for fanboys/girls (a-la "Gophers" or "Rustaceans")?

On a more serious note, the major issue with this language is that the tooling seems pretty bad.
The official language server used by the VSCode extension barely worked for me and ran super slow.
This was so annoying that I just uninstalled it and notepad-ed this source code -
which actually went quite smoothly which I'd say is an endorsement of how nice Nim's syntax is.

I also found the unit test situation to be pretty weird.
Nim's standard library comes with a bare-bones package `unittest` which can be run with `nimble test`.
It works fine though the reports are a bit ugly.
However, the distribution I downloaded from the Nim website seems to have included another program called `testament` which also runs unit tests.
Testament seems to require somewhat different formatting of unit tests so, if I am not mistaken, you can't use the same test code with `unittest`.
Including two incompatible unit test libraries with Nim kinda feels like split brain to me & I feel this stuff was not clearly explained in the language introduction on the Nim website.

One other issue that I did not run into here but which seems pretty critical to me is that there appears to be [some drama](https://forum.nim-lang.org/t/13322) around concurrency in Nim.
Having to use a library to get easy concurrency isn't _too_ bad.
But if this post is correct in claiming that some of the default concurrency-related compiler settings tank performance
that seems like a pretty huge red flag for anyone who would want to use Nim.
If it were me, at minimum I'd be worried about what other problems might get pushed onto me without my knowledge by poor defaults in new compiler versions.

With that, I think my final impression here is of a well-conceived core language surrounded by a bunch of rough edges.
It's a bit of a sad story because Nim is a really easy language to code and its ARC/ORC GC is a cool idea.

Ok, let's compare vs the other langs...

For lines of code - Nim blows the others out of the water.
I feel this is largely due to Nim's Pythonic syntax (you're saving one line for each block since you don't need a closing `}`).
The fact that memory management is automatic likely also plays a role.
Despite these advantages, I do believe Nim is a very concise language.

| Language | Lines of Code |
| -------- | ------------- |
| C        | 1456          |
| Ada      | 734           |
| C++      | 716           |
| Zig      | 701           |
| Odin     | 581           |
| Rust     | 568           |
| Nim      | 408           |

For how pleasant each language feels to code, I'd rank them: Odin == Nim == C++ > Ada > Rust >> Zig >> C.

In terms of how likely I would be to choose each language for an actual project, I'd rank them: C++ > Odin > Ada > Rust == Zig == C > Nim.
The VSCode langauge server being crap & the other apparent problems around the language rule it out for me as a legit contender.
Even ingoring the direct impact of the problems themselves, the fact that Nim has these problems (when other niche langs like Odin do not) creates an air of neglect around Nim's ecosystem.
