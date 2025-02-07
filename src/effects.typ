/// Sequence item with type `"call"`: adds a stack frame for calling the named function.
///
/// -> array
#let call(
  /// the function name to associate with the stack frame
  /// -> string
  name,
) = ((type: "call", name: name),)

/// Sequence item with type `"push"`: adds a variable to the current stack frame.
///
/// -> array
#let push(
  /// the new local variable being introduced
  /// -> string
  name,
  /// the value of the variable
  /// -> any
  value,
) = ((type: "push", name: name, value: value),)

/// Sequence item with type `"assign"`: assigns an already existing variable of the current stack
/// frame.
///
/// -> array
#let assign(
  /// the existing local variable being assigned
  /// -> string
  name,
  /// the value of the variable
  /// -> any
  value,
) = ((type: "assign", name: name, value: value),)

/// Sequence item with type `"return"`: pops the current stack frame.
///
/// -> array
#let ret() = ((type: "return"),)
