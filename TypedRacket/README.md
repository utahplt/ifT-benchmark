Typed Racket
===

Typed Racket adds gradual types to Racket.

* Language resources:
  - <https://docs.racket-lang.org/ts-reference/>
  - <https://github.com/racket/typed-racket>
  - <https://www2.ccs.neu.edu/racket/pubs/popl08-thf.pdf>
  - <https://www2.ccs.neu.edu/racket/pubs/icfp10-thf.pdf>
* If-T version: **1.0**
* Implementation: [./main.rkt](./main.rkt)


#### Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the dynamic type?
> If these types do not exist, explain the alternatives.

* Top = `Any`
* Bottom = `Nothing`
* Dynamic = N/A

There is no dynamic type, but Typed Racket can import from untyped code by using `require/typed`
and assigning a type annotation to each import.

In other words, Typed Racket has a fully static type system but allows its type context
to be inhabited by untyped values (which get checked dynamically, as typed code
interacts with them).

<https://docs.racket-lang.org/ts-reference/type-ref.html>


> Q. What base types does this implementation use? Why?

`String`, `Number`, and `Boolean`

These are simple, final base types in Typed Racket.


> Q. What container types does this implementation use (for objects, tuples, etc)? Why?

* Struct types for objects: search for `struct` in the code
* Pair and (sized) List types for tuples: `(Pairof T T)` and `(List T ....)`

Pairs have exactly 2 elements. We use pairs for the basic tuple benchmarks.

Lists can have any number of elements. We use lists for the sized-tuple benchmark.

By contrast, `Class` and `Object` types all have mutable fields. Typed Racket does
not allow narrowing on these fields to guarantee type soundness.


#### Type Narrowing

> Q. How do simple type tests work in this language?

Every base type has a built-in predicate. Every struct definition creates a predicate.

Examples: `(string? x)`, `(struct foo) .... (foo? x)`


> Q. Are there other forms of type test? If so, explain.

* `(assert x p)` succeeds if `(p x)` returns true and otherwise raises an error

<https://docs.racket-lang.org/ts-reference/Utilities.html>


> Q. How do type casts work in this language?

`(cast x T)`

Casts update the type environment and insert dynamic checks. The type `T` gets
compiled to a contract that either fully checks the value of `x` or puts a
wrapper around the value to check its future behavior. This works for almost
all types in Typed Racket (some types fail to compile). It can be expensive.


> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Symmetric predicates use the syntax `: T` after the function return type.

Example: `(-> Any (U Number #false) : String)`
  * this function takes 1 argument of any type
  * it returns either a number or `#false`
  * if it returns a number, the type of the argument is refined to `String`
  * and if it returns `#false`, the type of the argument is refined to not include `String`


> Q. If the language supports other type-narrowing predicates, describe them below.

There is an entire language of terms that can appear after a function return type to
describe type-narrowing predicates.

Examples:
* `(-> Any Boolean : #:+ Number)` : refines argument type only when the function returns `#true`
* `(-> Any Boolean : #:- Number)` : refines argument type only when the function returns `#false`
* `(-> Any Boolean : #:+ String #:- (! Number))` : refines to string in the true case, and to not-Number in the false case

<https://docs.racket-lang.org/ts-reference/type-ref.html#(part._.Other_.Type_.Constructors)>


#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

No, they are all expressible.

Some fail to typecheck, though.


> Q. Are any benchmarks expressed particularly well, or particularly poorly? Explain.

N/A


> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

Fairly direct:
* we introduce struct definitions for the object-properties benchmarks
* there are lots more parentheses because it's Racket


#### Advanced Examples

> Q. Are any examples inexpressible? Why?

_FILL in here_


> Q. Are any examples expressed particularly well, or particularly poorly? Explain.

_FILL in here_


> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

_FILL in here_



