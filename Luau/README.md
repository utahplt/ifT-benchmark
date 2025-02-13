# Luau

Luau is a typed-sister variant of Lua (it breaks backwards compatibility after
v5.1).

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

> Q. What base types does this implementation use? Why?

It uses `string`,`number` and `boolean`.

> Q. What container types does this implementation use (for objects, tuples,
> etc)? Why?

A Table in Luau is the base data structure for constructing complex objects or
organizing data. This implementation adopts `tables` for Lists, Structs and to
construct aliases for `Pairs` and `Tuples`.

#### Type Narrowing

> Q. How do simple type tests work in this language?

There are two main options: `typeof()` and `type()`. `typeof()`, comes shipped
with the typechecker and works on both Roblox data types and vanilla data types.

Example: `typeof(x) == "number"` or `type(x) == "number"`

> Q. Are there other forms of type test? If so, explain.

Yes, It also supports `IsA` for table instance refinements.

Example: `local x = Instance.new(Part); x:IsA("BasePart")`

> Q. How do type casts work in this language?

Type casts are done with the double colon (`::`) syntax.

Example: `x::unknown`

> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Luau does not supports these predicates yet.

> Q. If the language supports other type-narrowing predicates, describe them
> below.

Assertions (`assert`) can often be used to trigger type refinement.

#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

Luau is unable to express the type-narrowing predicate examples.

> Q. Are any benchmarks expressed particularly well, or particularly poorly?
> Explain.

No.

> Q. How direct (or complex) is the implementation compared to the pseudocode
> from If-T?

Very similar.

#### Advanced Examples

> Q. Are any examples inexpressible? Why?

```
define f(x: String | Number | Boolean) -> x is String:
    return x is String
```

Since Luau, does not support syntax for predicates on types, all the examples
(`predicate_checked`, `predicate_1way` and `predicate_2way`) are currently
inexpressible.

> Q. Are any examples expressed particularly well, or particularly poorly?
> Explain.

No.

> Q. How direct (or complex) is the implementation compared to the pseudocode
> from If-T?

Here is an example of the alias psuedocode by its Luau counterpart.

```
-- Luau implementation
function f(x: unknown): unknown
    local y = typeof(x) == "string"
    if y then
        return #x // type of x is not refined to String
    else
        return x
    end
end
```

```
-- psuedocode example: alias success

define f(x: Top) -> Top:
    let y = x is String
    if y:
        return String.length(x) // type of x is refined to String
    else:
        return x
```
