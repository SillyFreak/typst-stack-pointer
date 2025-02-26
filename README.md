# Stack Pointer

Stack Pointer is a library for visualizing the execution of (imperative) computer programs, particularly in terms of effects on the call stack: stack frames and local variables therein.

Stack Pointer lets you represent an example program (e.g. a C or Java program) using typst code with minimal hassle, and get the execution state of that program at different points in time.

## Getting Started

To add this package to your project, use this:

```typ
#import "@preview/stack-pointer:0.1.0": *

#execute(...)
```

For example, the following C program

```c
int main() {
  int x = foo();
  return 0;
}

int foo() {
  return 0;
}
```

would be represented by the following Typst code:

```typ
#let steps = execute({
  let foo() = func("foo", 6, l => {
    l(0)
    l(1); retval(0)
  })
  let main() = func("main", 1, l => {
    l(0)
    l(1)
    let (x, ..rest) = foo(); rest
    l(1, push("x", x))
    l(2)
  })
  main(); l(none)
})
```

The `steps` variable now contains an array, where each element corresponds to one of the mentioned lines of code.

## Usage

See the [manual](docs/manual.pdf) for details.

Take a look at [this complete example](gallery/sum.pdf) of using Stack Pointer together with [Touying](https://touying-typ.github.io/).
