# Luau

Luau is a typed-sister variant of Lua (it breaks backwards compatibility after
v5.1).

- Language resources:
  - <https://www.luau.org/>
  - <https://github.com/luau-lang/luau/>
  - <https://play.luau.org/>
- If-T version: **1.1**
- Implementation: [main.luau](main.luau)

#### Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the
> dynamic type? If these types do not exist, explain the alternatives.

- Top = `unknown`
- Bottom = `never`
- Dynamic = `any`

<https://luau.org/types/basic-types/#unknown-type>

> Q. What base types does this implementation use? Why?

`string`,`number`, and `boolean`. These are primitive types.

> Q. What container types does this implementation use (for objects, tuples,
> etc)? Why?

A Table in Luau is the base data structure for constructing complex objects or
organizing data. This implementation uses tables to encode lists, structs, and
tuples.

#### Type Narrowing

> Q. How do simple type tests work in this language?

Example: `typeof(x) == "number"`

<https://luau.org/types/type-functions/#type-function-environment>

> Q. Are there other forms of type test? If so, explain.

Yes, It also supports `IsA` and `is` for instance refinements. Assertions
(`assert`) can also trigger type refinement.

Example: `local x = Instance.new(Part); x:IsA("BasePart"); x:is("string")`\
Example: `assert(type(stringOrNumber) == "string")`

> Q. How do type casts work in this language?

Type casts are done with the double colon (`::`) syntax.

Example: `x::number`

> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Luau does not support predicates.

> Q. If the language supports other type-narrowing predicates, describe them
> below.

N/A

#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

Luau has no support for user-defined type narrowing predicates.

<https://luau.org/types/type-refinements/>

> Q. Are any benchmarks expressed particularly well, or particularly poorly?
> Explain.

The benchmarks are expressed well, but several fail to typecheck.

> Q. How direct (or complex) is the implementation compared to the pseudocode
> from If-T?

Luau has syntax to get the length of some sequence or iterable:

Example: `#x`

Luau also supports special syntax for string concatenation:

Example: `"Hello" .. "World"`

`~=` is a binary operator for not-equal comparisons.


#### Advanced Examples

> Q. Are any examples inexpressible? Why?

TODO

> Q. Are any examples expressed particularly well, or particularly poorly?
> Explain.

TODO

> Q. How direct (or complex) is the implementation compared to the pseudocode
> from If-T?

TODO

