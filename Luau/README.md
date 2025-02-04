# Luau

Luau is a typed-sister variant of Lua (3.8?)

- Language resources:
  - <https://www.luau.org/>
  - <https://github.com/luau-lang/luau/>
  - <https://github.com/luau-lang/luau/>
- If-T version: **1.0**
- Implementation: [main.luau](main.luau)

#### Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the
> dynamic type? If these types do not exist, explain the alternatives.

- Top = `unknown`
- Bottom = `never`
- Dynamic = `any`

> Q. What base types does this implementation use? Why? It uses `string`,
> `number` and `boolean`.

> Q. What container types does this implementation use (for objects, tuples,
> etc)? Why?

It construct aliases (on `tables`) for `Pairs` and `Tuples` but adopts the
`unknown` type for objects.

#### Type Narrowing

> Q. How do simple type tests work in this language?

There are two options: `typeof()` and `type()`, but `typeof()`, I belive, comes
with the typechecker and is not inherited from the host language.

Example: `typeof(x) == "number"` or `type(x) == "number"`

> Q. Are there other forms of type test? If so, explain.

> Q. How do type casts work in this language?

Type casts are done with the double colon (`::`) syntax.

Example: `x::unknown`

> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

I do not think Luau supports these predicates. Maybe type guards?

> Q. If the language supports other type-narrowing predicates, describe them
> below.

Assertions (`assert`) can often be used to trigger type refinement.

#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

The symmetric (2-way) type-narrowing predicates. This just uses the weaker
boolean type instead.

> Q. Are any benchmarks expressed particularly well, or particularly poorly?
> Explain.

> Q. How direct (or complex) is the implementation compared to the pseudocode
> from If-T?

Very similar.

#### Advanced Examples

> Q. Are any examples inexpressible? Why?

_FILL in here_

> Q. Are any examples expressed particularly well, or particularly poorly?
> Explain.

_FILL in here_

> Q. How direct (or complex) is the implementation compared to the pseudocode
> from If-T?

_FILL in here_
