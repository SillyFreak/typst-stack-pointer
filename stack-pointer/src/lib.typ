#import "@preview/polylux:0.3.1": only

// this utility is based on steps and actions. A step is a dict of the form
//    (line: <number>|none|SKIP, actions: (<action>, ...))
// unless the line is SKIP, a step results in a polylux subslide.

#let SKIP = "SKIP"

// Each action in a step defines what the step did to the stack:

// adds a stack frame for calling the named function
#let call(name) = (type: "call", name: name)
// adds a variable to the current stack frame
#let push(name, value) = (type: "push", name: name, value: value)
// assigns an already existing variable of the current stack frame
#let assign(name, value) = (type: "assign", name: name, value: value)
// pops the current stack frame
#let ret() = (type: "return")

// a step is usually created by the `l` function. That function does not return
// just a step, but an array of one step so that multiple `l` calls can be
// joined the name `l` refers to the fact that steps are closely associated with
// lines of code
//
// line: the line number (relative to `first-line`) to be highlighted at this step
//    if this (or first-line) is `none`, no line will be highlighted. If this is
//    `SKIP`, the actions will still be recorded but no subslide be created.
// first-line: the base line number; usually the first line of a function, so that
//    lines can be easily inserted without having to adjust subsequent functions
// ..actions: the actions that are part of this step
//
// returns: an array containing a single step
#let l(line, ..actions, first-line: 0) = {
  assert(actions.named().len() == 0)
  let line = if line == SKIP {
    SKIP
  } else if first-line != none and line != none {
    first-line + line
  }
  // return an array with one step in it. when called multiple times,
  // the arrays will be joined
  ((line: line, actions: actions.pos()),)
}

// a pseudo-step recognized `simulate-func`. A simulated function may generate
// this as its last "step" to signify its return value. A function that doesn't
// use this can simply be called by another simulated function like this:
//
//    my-func(a, b)
//
// which will result in its steps being put into the sequence where it is
// called. A function that calls `exit()` is called like this:
//
//    let (result, ..steps) = my-func(a, b); steps
//
// here, the result given to `exit()` is destructured into its own variable,
// and the steps are emitted so that they appear in the sequence of steps.
//
// `exit()` being called multiple times or not after any other steps is an
// error.
#let exit(result) = ((result: result),)

// a helper for writing functions that produce an array of steps. This function
// automatically inserts call and return actions (in a step with SKIP). If you
// want to display the call step, just insert a visible step at the beginning
// of your simulation; for the return step, do the same directly after calling
// the function.
//
// name: the name of the function; used for the call action
// first-line: the line at which the simulated function starts
// callback: simulates the function, receives `l.with(first-line: first-line)`,
//    which makes creating steps more convenient.
//
// returns: the sequence of steps. If `exit` was called, the result value is
//    the first element and needs to be consumed by the caller. After that,
//    there's the SKIPped call step, the steps from the simulation, and the
//    SKIPped return step.
#let simulate-func(name, first-line, callback) = {
  // evaluate the function
  let steps = callback(l.with(first-line: first-line))

  // if there was an exit(), extract it and the value from it
  let result = if "result" in steps.last().keys() {
    (steps.remove(steps.len() - 1).result,)
  }

  // if there is exit() anywhere else, that's an error
  assert(
    steps.all(step => "result" not in step.keys()),
    message: "only one exit() at the end of a function execution is allowed: " + repr(steps)
  )

  // prepend the result, if any
  result
  // assemble the final steps
  l(SKIP, call(name))
  steps
  l(SKIP, ret())
}

// for each subslide (non-SKIPped step) that has an associated line (not none),
// renders the current line at that step.
#let line-markers(steps, render) = {
  let when = 0
  for step in steps {
    // for line markers, there's nothing to do at SKIPped steps
    // just make sure that we're not even incrementing the subslide counter
    if step.line == SKIP { continue }
    when += 1

    if step.line != none {
      // this step has an associated line;
      // render the highlight only in the specific subslide
      only(when, render(step))
    }
  }
}

// Processes all actions. For each subslide (non-SKIPped step), renders the
// state after the current step.
#let stack(steps, render) = {
  let stack = ()

  let when = 0
  for step in steps {
    // apply the actions of the current step
    for (type: t, ..action) in step.actions {
      if t == "call" {
        stack.push((..action, vars: ()))
      } else if t == "push" {
        stack.last().vars.push(action)
      } else if t == "assign" {
        let index = stack.last().vars.position(x => x.name == action.name)
        stack.last().vars.at(index) = action
      } else if t == "pop" {
        let _ = stack.last().vars.pop()
      } else if t == "return" {
        let _ = stack.pop()
      } else {
        panic(t)
      }
    }

    // rendering only happens for non-SKIPped steps
    // just make sure that we're not even incrementing the subslide counter
    if step.line == SKIP { continue }
    when += 1

    // render that state only in the specific subslide
    only(when, render(stack))
  }
}
