#import "/src/lib.typ" as stack-pointer

// the output is not relevant for this test
#set page(width: 0pt, height: 0pt)

#let execution = {
  import stack-pointer: *

  // 1: int main() {
  // 2:   int x = foo();
  // 3:   return 0;
  // 4: }
  // 5
  // 6: int foo() {
  // 7:   return 0;
  // 8: }

  execute({
    let foo() = func("foo", 6, l => {
      l(0)
      l(1); retval(0)  // (1)
    })
    let main() = func("main", 1, l => {
      l(0)
      l(1)
      let (x, ..rest) = foo(); rest  // (2)
      l(1, push("x", x))
      l(2)
    })
    main(); l(none)
  })
};

#let step(line, stack) = (step: (line: line), state: (stack: stack))

#assert.eq(execution, (
  step(1, ((name: "main", vars: (:)),)),
  step(2, ((name: "main", vars: (:)),)),
  step(6, ((name: "main", vars: (:)), (name: "foo", vars: (:)))),
  step(7, ((name: "main", vars: (:)), (name: "foo", vars: (:)))),
  step(2, ((name: "main", vars: (x: 0)),)),
  step(3, ((name: "main", vars: (x: 0)),)),
  step(none, ()),
))
