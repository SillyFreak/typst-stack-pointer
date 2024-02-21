// #import "@preview/stack-pointer:0.1.0"
// #import "@local/stack-pointer:0.0.1"
#import "../src/lib.typ" as stack-pointer

#import "@preview/polylux:0.3.1": *
#import themes.simple: *

// make the PDF reproducible to ease version control
#set document(date: none)

#show: simple-theme

#{
  import stack-pointer: *

  let code = ```java
    void main(String[] args) {
      int a = 2, b = 3, c = 4;
      int d = sum(a, b, c);
      System.out.println(d);
    }
    void sum(int x, int y, int z) {
      int result = add(x, y);
      result = add(result, z);
      return result;
    }
    void add(int x, int y) {
      int result = x + y;
      return result; }
  ```

  // this is where the magic happens: we simulate the above java code,
  // generating an array of steps with all the actions that influence the
  // call stack
  let steps = {
    // println returns nothing, so it's easy to define and use
    // it's also not part of the shown code, so the line numbers are `none`
    let println(x) = simulate-func("println", none, l => {
      // always begin with adding the parameter variables
      l(none, push("x", x))

      l(none, call("..."))
      l(none, ret())

      // there's no exit() here, so the result is itself a list of only steps
    })

    // this is a function with return value. calling it needs some care
    let add(x, y) = simulate-func("add", 11, l => {
      l(0, push("x", x), push("y", y))

      // int result = x + y;
      l(1)
      let result = x + y
      // a new variable, push it
      l(1, push("result", result))

      // return result;
      l(2)
      // the exit/return value will be first in the result of `add()`.
      // it needs to be removed by the caller, so that the end result
      // contains only the steps for the subslides
      exit(result)
    })

    let sum(x, y, z) = simulate-func("sum", 6, l => {
      l(0, push("x", x), push("y", y), push("z", z))

      // int result = add(x, y);
      l(1)
      // here we call a function with return value. We separate the return
      // value from the steps. The result is kept in a variable and ...
      let (result, ..steps) = add(x, y); steps
      //   ... the steps are joined here ^^^^^ with the rest
      l(1, push("result", result))

      // result = add(result, z);
      l(2)
      let (result, ..steps) = add(result, z); steps
      l(2, assign("result", result))

      // return result;
      l(3)
      exit(result)
    })

    let main() = simulate-func("main", 1, l => {
      l(0, push("args", [_\<reference\>_]))

      // int a = 2, b = 3, c = 4;
      l(1)
      let a = 2
      l(1, push("a", a))
      let b = 3
      l(1, push("b", b))
      let c = 4
      l(1, push("c", c))

      // int d = sum(a, b, c);
      l(2)
      let (d, ..steps) = sum(a, b, c); steps
      l(2, push("d", d))

      // System.out.println(d);
      l(3)
      // here we call a function without return value. We can just write it
      // as-is
      println(d)
      // because we want to show the stack in the state after println()
      // returned, add a step here back in the main method
      l(3)
    })

    // call the main function, which returns all steps for generating the subslides
    main()
    // after the main() call, I also want to show the empty stack,
    // so add a subslide on the final line of main()
    l(5)
  }

  // when generating the slide, it's crucial to specify the max-repetitions
  polylux-slide(max-repetitions: steps.len())[
    == Program execution and the stack


    #set text(size: 0.8em)
    #grid(columns: (50%, 1fr), {
      line-markers(steps, step => place(
        dx: -1em,
        // this is hard-coded for the specific font - could be more flexible
        dy: -0.0em + (step.line - 1) * 1.12em,
        sym.arrow
      ))

      code
    }, {
      [Stack:]
      stack(steps, stack => list(
        // make a list of all stack frames of the current state
        ..stack.map(frame => {
          frame.name
          if frame.vars.len() != 0 {
            [: ]
            frame.vars.map(((name, value)) => [#name~=~#value]).join[, ]
          }
        })
      ))
    })
  ]
}