TypeScript
===

TypeScript is a typechecker for JavaScript by Microsoft.

* Language resources:
  - <https://www.typescriptlang.org/>
  - <https://github.com/microsoft/TypeScript>
  - <https://www.typescriptlang.org/play>
* If-T version: **1.0**
* Implementation: [./main.ts](./main.ts)


#### Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the dynamic type?
> If these types do not exist, explain the alternatives.

* Top = `unknown`
* Bottom = `never`
* Dynamic = `any`

<https://www.typescriptlang.org/docs/handbook/type-compatibility.html#any-unknown-object-void-undefined-null-and-never-assignability>


> Q. What base types does this implementation use? Why?

`string`, `number`, and `boolean`

These are simple, final base types in TypeScript.


> Q. What container types does this implementation use (for objects, tuples, etc)? Why?

* Object types for objects: `{name: type, ...}`
* Array types for tuples: `[type, ...]`

Both these types describe mutable data, but TypeScript still allows type narrowing on
their elements.


#### Type Narrowing

> Q. How do simple type tests work in this language?

`typeof x` returns a string that can be compared to other string literals.

Example: `typeof x === "number"`


> Q. Are there other forms of type test? If so, explain.

None that we are aware of.


> Q. How do type casts work in this language?

`x as number`

Casts assert facts to the typechecker, but these facts are not enforced
dynamically. If `x` is cast to `number` it could still evaluate to a string.


> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Symmetric predicates use the syntax `x is T` as their return type.

Example: `function f(x: mixed): x is string { .... }`


> Q. If the language supports other type-narrowing predicates, describe them below.

N/A


#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

No, they are all expressible.

Some fail to typecheck, though.


> Q. Are any benchmarks expressed particularly well, or particularly poorly? Explain.

N/A


> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

Very direct.


#### Advanced Examples

> Q. Are any examples inexpressible? Why?

`tree_node` in the failure case passes typechecking (incorrectly).
This is because TypeScript trusts all user-defined predicates to match their types.


> Q. Are any examples expressed particularly well, or particularly poorly? Explain.

- The `flatten` example has a slightly different implementation than the pseudocode from If-T, since the `empty?` predicate in the pseudocode checks both if the argument is an array and if it is empty, and this must be done in two separate steps in TypeScript.
- The `rainfall` example uses type `unknown` instead of a `JSON` type, since every value in JavaScript (hence TypeScript) is representing a legitimate JSON value. Also, it has 2 extra null tests: on the object `day` and its field `rainfall`.

> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

Very direct.
