MLsem
===

MLsem is a prototype type checker for dynamic languages based on set-theoretic
types.

* Language resources:
  - <https://github.com/E-Sh4rk/MLsem>
  - <https://e-sh4rk.github.io/MLsem/doc.html>
* If-T version: **1.1**
* Implementation: [./main.ml](./main.ml), [./examples.ml](./examples.ml)
* Raw command to run the benchmark: `racket check-mlsem.rkt <path-to-file>`
  (this wraps `mlsem -notime <path-to-file>` so printed MLsem errors become a
  non-zero exit status)

#### Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the dynamic type?
> If these types do not exist, explain the alternatives.

* Top = `any`
* Bottom = `empty`
* Dynamic = `any` for benchmark inputs. MLsem also accepts `dyn` as a cast or
  coercion target for dynamic typing.


> Q. What base types does this implementation use? Why?

`string`, `int`, and `bool`

These are simple MLsem base types corresponding to the If-T benchmark's string,
number, and boolean cases.


> Q. What container types does this implementation use (for objects, tuples, etc)? Why?

* Records: `{ a:any }`, `{ rainfall:any? ..}`
* Pairs/tuples: `(any, any)`
* Sequence types: `[int int]`, `[string string string]`, `[int*]`

These are MLsem-native structural container types and support typecase-based
narrowing.


#### Type Narrowing

> Q. How do simple type tests work in this language?

MLsem uses typecase syntax: `if x is int then ... else ...`.


> Q. Are there other forms of type test? If so, explain.

Type tests can use set-theoretic type expressions such as unions, intersections,
negation, record types, tuple/sequence types, and recursive types.


> Q. How do type casts work in this language?

MLsem supports casts like `(x : int)` and coercions like `(x :> int)`, with
unchecked variants documented by MLsem. The benchmark implementation does not
use casts to force expected results.


> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Two-way predicates are functions with precise singleton-boolean return types.

Example: `(string -> true) & (~string -> false)`.


> Q. If the language supports other type-narrowing predicates, describe them below.

One-way predicates can be expressed by leaving the positive case imprecise, e.g.
`(int -> bool) & (string -> false)`.


#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

All core benchmarks are expressible. The observed result for `connectives` is
`x`: MLsem does not retain enough refinement through the helper-level conjunction
of negated predicate results in the `connectives_success_h` case.


> Q. Are any benchmarks expressed particularly well, or particularly poorly? Explain.

Recursive and structural cases are concise because MLsem supports set-theoretic
record, tuple, sequence, and recursive types directly.


> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

Mostly direct. Some operations are represented as declared primitives because
the benchmark only needs static checking behavior.


#### EXAMPLES.md : Example Programs

> Q. Are any examples inexpressible? Why?

No. All example programs produce `O` with the current implementation.


> Q. Are any examples expressed particularly well, or particularly poorly? Explain.

`tree_node` and `flatten` are compact because recursive types and sequence types
are native MLsem concepts. `rainfall` is written as a recursive accumulation over
records to focus on field and range narrowing.


> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

The examples are direct at the type-narrowing level, with minor structural
adaptations to MLsem syntax.
