/// Adds two numbers.
/// Example: $1 + 2 = #sp.add(1, 2)$
///
/// - x (number): the first summand
/// - y (number): the second summand
/// -> number
#let add(x, y) = x + y

/// Subtracts the second number from the first.
/// Example: $1 - 2 = #sp.sub(1, 2)$
///
/// - x (number): the minuend
/// - y (number): the subtrahend
/// -> number
#let sub(x, y) = x - y

/// Multiplies two numbers.
/// Example: $1 dot.c 2 = #sp.mul(1, 2)$
///
/// - x (number): the first factor
/// - y (number): the second factor
/// -> number
#let mul(x, y) = x * y

/// Divides the first number by the second.
/// Example: $1 div 2 = #sp.div(1, 2)$
///
/// - x (number): the dividend
/// - y (number): the divisor
/// -> number
#let div(x, y) = x / y
