# Introduction

This repository contains an implementation of the [Shunting-Yard](https://en.wikipedia.org/wiki/Shunting-yard_algorithm) algorithm.

This algorithm is used to convert infix expressions (ex: `1+2+3`) into postfix expressions, or reversed Polish notation (ex: `1 2 + 3 +`).

# Dependencies

You must install the CPAN package [`HOP::Parser`](https://github.com/dbeurive/shunting-yard).

Just type: `cpan -i HOP::Parser`

# Usage

Assuming that you have GNU Make installed :

Go in the repository's directory, and type the following command: `make test`

Otherwise, just type `perl test.pl`.

# Examples

  Infix:  1+2
  RPN:    1, 2, +

  Infix:  1+2+3
  RPN:    1, 2, +, 3, +

  Infix:  1+2*3
  RPN:    1, 2, 3, *, +

  Infix:  1+2-3*4
  RPN:    1, 2, +, 3, 4, *, -

  Infix:  1+2*(3-4)
  RPN:    1, 2, 3, 4, -, *, +

  Infix:  sin(cos(3+4*8))
  RPN:    3, 4, 8, *, +, cos, sin

  Infix:  1+~3
  RPN:    1, 3, ~, +

  Infix:  1+3+6^4*8
  RPN:    1, 3, +, 6, 4, ^, 8, *, +

  Infix:  1/2*3+12%
  RPN:    , 2, /, 3, *, 12, %, +

  Infix:  1+2/3 > 10
  RPN:    1, 2, 3, /, +, 10, >

  Infix:  (1+3+2+5)/5^2 > 3+3+4
  RPN:    1, 3, +, 2, +, 5, +, 5, 2, ^, /, 3, 3, +, 4, +, >

  Infix:  ~(1+2/3%) >= sin(~32)
  RPN:    1, 2, 3, %, /, +, ~, 32, ~, sin, >=

  Infix:  f1(f2(1+2+3, 10%, ~3), f3())
  RPN:    1, 2, +, 3, +, 10, %, 3, ~, f2, f3, f1

  Infix:  1+V13/3%
  RPN:    1, V13, 3, %, /, +

  Infix:  f1(v2+V34/sin(V55)) > 10^V5
  RPN:    V34, V55, sin, /, +, v2, f1, 10, V5, ^, >

  Infix:  "foo" & "bar"
  RPN:    "foo", "bar", &

  Infix:  "foo" & "bar" = "foobar"
  RPN:    "foo", "bar", &, "foobar", =

  Infix:  "foo" & "bar" <> "toto"
  RPN:    "foo", "bar", &, "toto", <>
