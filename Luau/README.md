# Luau

Luau is a typed-sister variant of Lua (it breaks backwards compatibility after
v5.1).

- Language resources:
  - <https://www.luau.org/>
  - <https://github.com/luau-lang/luau/>
- If-T version: **1.0**
- Implementation: [main.luau](main.luau)

#### Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the
> dynamic type? If these types do not exist, explain the alternatives.

- Top = `unknown`
- Bottom = `never`
- Dynamic = `any`

> Q. What base types does this implementation use? Why?

It uses `string`,`number` and `boolean`.

> Q. What container types does this implementation use (for objects, tuples,
> etc)? Why?

A Table in Luau is the base data structure for constructing complex objects or
organizing data. This implementation adopts `tables` for Lists, Structs and to
construct aliases for `Pairs` and `Tuples`.

#### Type Narrowing

> Q. How do simple type tests work in this language?

Example: `typeof(x) == "number"`

> Q. Are there other forms of type test? If so, explain.

Yes, It also supports `IsA` and `is` for instance refinements. Assertions
(`assert`) can also trigger type refinement.

Example: `local x = Instance.new(Part); x:IsA("BasePart"); x:is("string")`\
Example: `assert(type(stringOrNumber) == "string")`

> Q. How do type casts work in this language?

Type casts are done with the double colon (`::`) syntax.

Example: `x::number`

> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Luau does not supports these predicates yet.

> Q. If the language supports other type-narrowing predicates, describe them
> below.

#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

Luau is unable to express the type-narrowing predicate examples. The new solver
supports
[type functions](https://rfcs.luau.org/user-defined-type-functions.html), which
should be ideal for implementing this, however, parameters are not allowed to be
referenced in the return type.

```
type function isString(T)
  return types.singleton(T:is("string"))
end

-- luau flags both instances of x in the signature as being in different scopes
function predicate_2way_success_f(x: string | number): isString<x>
 return typeof(x) == "string"
end
```

> Q. Are any benchmarks expressed particularly well, or particularly poorly?
> Explain.

```
define f(x: String | Number | Boolean) -> x is String:
    return x is String
```

Since Luau, does not currently provide a direct way to connect a function
parameter to its returned type information in this manner, all the related
examples (`predicate_checked`, `predicate_1way` and `predicate_2way`) are
currently inexpressible.

> Q. How direct (or complex) is the implementation compared to the pseudocode
> from If-T?

Very similar. Luau has some special syntax to get the length of some sequence or
iterable.

Example: `#x`

It also supports special syntax for string concatenation.

Example: `"Hello" .. "World"`

#### Advanced Examples

> Q. Are any examples inexpressible? Why?

No.

> Q. Are any examples expressed particularly well, or particularly poorly?
> Explain.

No.

> Q. How direct (or complex) is the implementation compared to the pseudocode
> from If-T?

Very similar.
