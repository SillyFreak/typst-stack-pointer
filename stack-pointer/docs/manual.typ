#import "@preview/tidy:0.2.0"

#import "template.typ": *

#import "../src/lib.typ" as sp

#let package-meta = toml("../typst.toml").package
#let date = none
// #let date = datetime(year: ..., month: ..., day: ...)

#show: project.with(
  title: "Stack Pointer",
  // subtitle: "...",
  authors: package-meta.authors.map(a => a.split("<").at(0).trim()),
  abstract: [
    _Stack Pointer_ is a library for visualizing the execution of (imperative) computer programs, particularly in terms of effects on the call stack: stack frames and local variables therein.
  ],
  url: package-meta.repository,
  version: package-meta.version,
  date: date,
)

// the scope for evaluating expressions and documentation
#let scope = (sp: sp)

= Introduction

This is a template for typst packages. It provides, for example, the #ref-fn("sp.add()") function.

= Module reference

== `template`

#{
  let module = tidy.parse-module(
    read("../src/lib.typ"),
    label-prefix: "sp.",
    scope: scope,
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}
