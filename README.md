# ot-benchmark

Benchmark for Occurrence Typing (and Similar Techniques).

Occurrence typing is more widely known as "type narrowing" or "type refinement" these days. It is a technique that refines the type of a variable based on the occurrence of certain predicates. It is originally proposed by Tobin-Hochstadt and Felleisen in their paper "Logical Types for Untyped Languages" at ICFP 2010:

``` bibtex
@inproceedings{tobin-hochstadtLogicalTypesUntyped2010,
  title = {Logical Types for Untyped Languages},
  booktitle = {{ICFP}},
  author = {Tobin-Hochstadt, Sam and Felleisen, Matthias},
  date = {2010-09-27},
  pages = {117--128},
  publisher = {{ACM}},
  doi = {10.1145/1863543.1863561},
}
```

For some instances, see
- [Typed Racket guide on occurrence typing](https://docs.racket-lang.org/ts-guide/occurrence-typing.html)
- [TypeScript documentation on narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)
- [Flow documentation on type refinements](https://flow.org/en/docs/lang/refinements/#toc-refinement-invalidations)
- [Mypy documentation on type narrowing](https://mypy.readthedocs.io/en/stable/type_narrowing.html#typeguards-with-parameters)
- [https://github.com/microsoft/pyright/blob/main/docs/type-concepts-advanced.md#type-narrowing](Pyright documentation on type narrowing)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->

## Table of Contents

  - [Examples](#examples)
  - [The Benchmark](#the-benchmark)
    - [`positive`](#positive)
    - [`negative`](#negative)
    - [`alias`](#alias)
    - [`connectives`](#connectives)
    - [`nesting_body`](#nesting_body)
    - [`nesting_condition`](#nesting_condition)
    - [`predicate_2way`](#predicate_2way)
    - [`predicate_1way`](#predicate_1way)
    - [`predicate_checked`](#predicate_checked)
    - [`object_properties`](#object_properties)
    - [`tuple_elements`](#tuple_elements)
    - [`tuple_length`](#tuple_length)
    - [`subtyping_nominal`](#subtyping_nominal)
    - [`subtyping_structural`](#subtyping_structural)
    - [`merge_with_union`](#merge_with_union)
  - [Benchmark Results](#benchmark-results)
  - [Uncertain Benchmark Items](#uncertain-benchmark-items)
    - [`predicate_extra_args`](#predicate_extra_args)
    - [`predicate_multi_args`](#predicate_multi_args)
  - [Other Discussions](#other-discussions)
    - [refinement invalidation](#refinement-invalidation)
    - [unknown to known length](#unknown-to-known-length)
  - [Acknowledge](#acknowledge)

<!-- markdown-toc end -->

## Examples

For a set of code examples that demonstrate the features of occurrence typing, see [Examples.md](Examples.md)

## The Benchmark

From the examples, we can summarize the common features or "API"s that one would expect from a gradual type checker that supports occurrence typing. Each feature, with a brief description, the guarantee it provides, and the examples that demonstrate it, forms a benchmark item. All the benchmark items are listed below.

### `positive`

#### Description

If the predicate is true, the type of the variable is refined to a more specific type with the information that the predicate holds.

#### Examples

##### Success Expected

```text
define f(x: Top) -> Top:
    if x is String:
        return String.length(x) // type of x is refined to String
    else:
        return x
```

##### Failure Expected

```text
define f(x: Top) -> Top:
    if x is String:
        return x + 1 // type of x is refined to String, adding a number to a string is not allowed
    else:
        return x
```

### `negative`

#### Description

If the predicate is false, the type of the variable is refined to a more specific type with the information that the negation of the predicate holds.

#### Examples

##### Success Expected

```text
define f(x: String | Number) -> Number:
    if x is String:
        return String.length(x)
    else:
        return x + 1 // type of x is refined to Number, namely (String | Number) - String
```

##### Failure Expected

```text
define f(x: String | Number | Boolean) -> Number:
    if x is String:
        return String.length(x)
    else:
        return x + 1 // type of x is refined to Number | Boolean, thus not allowing addition
```

### `alias`

#### Description

When the result of a predicate test is bound to an immutable variable, that variable can also be used as a type guard. When the result of a predicate test is bound to a mutable variable, that variable can be used as a type guard only if it is not updated.

#### Examples

##### Success Expected

```text
define f(x: Top) -> Top:
    let y = x is String
    if y:
        return String.length(x) // type of x is refined to String
    else:
        return x
```

##### Failure Expected

```text
define f(x: Top) -> Top:
    let y = x is String
    if y:
        return x + 1 // type of x is refined to String, adding a number to a string is not allowed
    else:
        return x

define g(x: Top) -> Top:
    var y = x is String // y is mutable
    y = true
    if y:
        return String.length(x) // since y is updated, type of x is not refined
    else:
        return x
```

### `connectives`

#### Description

When a predicate is a conjunction of multiple predicates, the type of the variable is refined to the intersection of the types refined by each predicate. When a predicate is a disjunction of multiple predicates, the type of the variable is refined to the union of the types refined by each predicate. When a predicate is a negation of another predicate, the type of the variable is refined to the complement of the type refined by the negated predicate.

#### Examples

##### Success Expected

```text
define f(x: String | Number) -> Number:
    if not (x is Number):
        return String.length(x)
    else:
        return 0

define g(x: Top) -> Number:
    if x is String or x is Number:
        return f(x) // type of x is refined to String | Number, thus allowing the call to f
    else:
        return 0

define h(x: String | Number | Boolean) -> Number:
    if not (x is Boolean) and not (x is Number):
        return String.length(x)
    else:
        return 0
```

##### Failure Expected

```text
define f(x: String | Number) -> Number:
    if not (x is Number):
        return x + 1 // type of x is refined to String, adding a number to a string is not allowed
    else:
        return 0

define g(x: Top) -> Number:
    if x is String or x is Number:
        return x + 1 // type of x is refined to String | Number, thus not allowing addition
    else:
        return 0

define h(x: String | Number | Boolean) -> Number:
    if not (x is Boolean) and not (x is Number):
        return x + 1 // type of x is refined to String | Boolean, thus not allowing addition
    else:
        return 0
```

### `nesting_body`

#### Description

When a conditional statement is nested inside the body of another conditional statement, the type of the variable is refined to the intersection of the types refined by each conditional statement.

#### Examples

##### Success Expected

```text
define f(x: String | Number | Boolean) -> Number:
    if not (x is String):
        if not (x is Boolean):
            return x + 1 // type of x is refined to Number
        else:
            return 0
    else:
        return 0
```

##### Failure Expected

```text
define f(x: String | Number | Boolean) -> Number:
    if x is String | Number:
        if x is Number | Boolean:
            return String.length(x) // type of x is Number
        else:
            return 0
    else:
        return 0
```

### `nesting_condition`

#### Description

When a conditional statement is nested inside the condition of another conditional statement, the type of the variable is refined to the intersection of the types refined by each conditional statement.

#### Examples

##### Success Expected

```text
define f(x: Top, y: Top) -> Number:
    if (if x is Number: y is String else: false)
        x + String.length(y) // type of x is refined to Number, type of y is refined to String
    else
        0
```

##### Failure Expected

```text
define f(x: Top, y: Top) -> Number:
    if (if x is Number: y is String else: y is String)
        x + String.length(y) // type of x is not clear here, thus not allowing addition
    else
        0
```

### `predicate_2way`

#### Description

When a custom predicate is true, the type of the variable is refined to a more specific type with the information that the predicate holds. When a custom predicate is false, the type of the variable is refined to a more specific type with the information that the negation of the predicate holds.

#### Examples

##### Success Expected

```text
define f(x: String | Number) -> x is String:
    return x is String

define g(x: String | Number) -> Number:
    if f(x):
        return String.length(x) // type of x is refined to String
    else:
        return x // type of x is refined to Number, namely (String | Number) - String
```

##### Failure Expected

```text
define f(x: String | Number) -> x is String:
    return x is String

define g(x: String | Number) -> Number:
    if f(x):
        return x + 1 // type of x is refined to String, adding a number to a string is not allowed
    else:
        return x // type of x is refined to Number, namely (String | Number) - String
```

### `predicate_1way`

#### Description

When a custom predicate is true, the type of the variable is refined to a more specific type with the information that the predicate holds. When a custom predicate is false, the type of the variable is not refined. This is helpful for predicates that are underapproximations.

#### Examples

##### Success Expected

```text
define f(x: String | Number) -> implies x is Number:
    return x is Number and x > 0

define g(x: String | Number) -> Number:
    if f(x):
        return x + 1 // type of x is refined to Number
    else:
        return 0
```

##### Failure Expected

```text
define f(x: String | Number) -> implies x is Number:
    return x is Number and x > 0

define g(x: String | Number) -> Number:
    if f(x):
        return x + 1 // type of x is refined to Number
    else:
        return String.length(x) // type of x is not refined, thus not compatible with the return type
```

### `predicate_checked`

#### Description

The type checker checks that the assertion made by a custom predicate is compatible with the type of the variable, instead of just accepting what the programmer asserts.

#### Examples

##### Success Expected

```text
define f(x: String | Number) -> x is String:
    return x is String

define g(x: String | Number) -> Number:
    if f(x):
        return String.length(x) // type of x is refined to String
    else:
        return x // type of x is refined to Number, namely (String | Number) - String
```

##### Failure Expected

```text
define f(x: String | Number) -> x is Boolean: // should not type check
    return x is Boolean

define g(x: String | Number) -> Number:
    return true // not really checking the type of x, should not type check
```

### `object_properties`

#### Description

Partially refine the type of objects, that is, when the predicate is applied to an object property, refine the type of the object property.

#### Examples

##### Success Expected

```text
struct Apple:
    a: Top

define f(x: Apple) -> Number:
    if x.a is Number:
        return x.a // type of x.a is refined to Number
    else:
        return 0
```

##### Failure Expected

```text
struct Apple:
    a: Top

define f(x: Apple) -> Number:
    if x.a is String:
        return x.a // type of x.a is refined to String, thus not allowing the return
    else:
        return 0
```

### `tuple_elements`

#### Description

When appropriate predicates are applied to the elements of a tuple, refine the type of the elements of the tuple.

#### Examples

##### Success Expected

```text
define f(x: Tuple(Top, Top)) -> Number:
    if x[0] is Number:
        return x[0] // type of x[0] is refined to Number, type of x is refined to Tuple(Number, Top)
    else:
        return 0
```

##### Failure Expected

``` text
define f(x: Tuple(Top, Top)) -> Number:
    if x[0] is Number:
        return x[0] + x[1] // type of x[0] is refined to Number, but type of x[1] is not clear
    else:
        return 0
```

### `tuple_length`

#### Description

When refining a variable with the type as a union of tuple types, refine the type of the variable by the length of the tuple.

#### Examples

##### Success Expected

```text
define f(x: Tupleof(Number, Number) | Tupleof(String, String, String)) -> Number:
    if Tuple.length(x) is 2:
        return x[0] + x[1] // type of x is refined to Tupleof(Number, Number)
    else:
        return String.length(x[0]) // type of x is refined to Tupleof(String, String, String)
```

##### Failure Expected

```text
define f(x: Tupleof(Number, Number) | Tupleof(String, String, String)) -> Number:
    if Tuple.length(x) is 2:
        return x[0] + x[1] // type of x is refined to Tupleof(Number, Number)
    else:
        return x[0] + x[1] // type of x is refined to Tupleof(String, String, String), thus not allowing addition
```

### `subtyping_nominal`

#### Description

Refine supertypes to subtypes in a nominal subtyping scheme.

#### Examples

##### Success Expected

```text
struct A:
    a: Number

struct B extends A:
    b: Number

define f(x: A) -> Number:
    if x is B:
        return x.b // type of x is refined to B
    else:
        return x.a // type of x is refined to A
```

##### Failure Expected

```text
struct A:
    a: Number

struct B extends A:
    b: Number

define f(x: A) -> Number:
    if x is B:
        return x.a
    else:
        return x.b // type of x is refined to A which does not have a property b
```

### `subtyping_structural`

#### Description

Refine supertypes to subtypes in a structural subtyping scheme.

#### Examples

##### Success Expected

```text
define f(x: Top) -> String:
    return "hello"

define g(f: Number -> String | Boolean) -> String:
    if f(0) is String:
        return f(0) // type of f(0) is refined to String
    else:
        return "world"

g(f) // this should type check
```

##### Failure Expected

```text
define f(x: Number) -> String:
    return "hello"

define g(f: Top -> String | Boolean) -> String:
    if f(0) is String:
        return f(0) // type of f(0) is refined to String
    else:
        return "world"

g(f) // this should not type check
```

### `merge_with_union`

#### Description

When multiple branches where the type of a variable is refined to different types are merged, the type of the variable is refined to the union of the types refined by each branch, instead of joining the types, that is, taking the common supertype.

#### Examples

##### Success Expected

```text
define f(x: Top) -> String | Number:
    if x is String:
        String.append(x, "hello") // type of x is refined to String
    else if x is Number:
        x = x + 1 // type of x is refined to Number
    else:
        return 0
    return x // type of x is refined to String | Number; a bad implementation will refine to Top
```

##### Failure Expected

```text
define f(x: Top) -> String | Number:
    if x is String:
        String.append(x, "hello") // type of x is refined to String
    else if x is Number:
        x = x + 1 // type of x is refined to Number
    else:
        return 0
    return x + 1 // type of x is refined to String | Number
```

## Benchmark Items Table

Below is a table for all benchmark items as a quick reference.
| Benchmark            | Description                                              |
|:---------------------|----------------------------------------------------------|
| positive             | refine when condition is true                            |
| negative             | refine when condition is false                           |
| alias                | track test results assigned to variables                 |
| connectives          | handle logic connectives                                 |
| nesting_body         | nested conditionals with nesting happening in body       |
| nesting_condition    | nested conditionals with nesting happening in condition  |
| predicate_2way       | custom predicates refines both positively and negatively |
| predicate_1way       | custom predicates refines only positively                |
| predicate_checked    | perform strict type checks on custom predicates          |
| object_properties    | refine types of properties of objects                    |
| tuple_elements       | refine types of tuple elements                           |
| tuple_length         | refine union of tuple types by their length              |
| subtyping_nominal    | refine nominal subtyping                                 |
| subtyping_structural | refine structural subtyping                              |
| merge_with_union     | merge several types with union instead of joining        |

## Benchmark Results

The benchmark is performed on the following gradual type checker implements.

*   Typed Racket
*   TypeScript
*   Flow
*   mypy
*   Pyright

The result is as follows.

| Benchmark            | Typed Racket | TypeScript | Flow | mypy | Pyright |
|:---------------------|--------------|------------|------|------|---------|
| positive             |              |            |      |      |         |
| negative             |              |            |      |      |         |
| alias                |              |            |      |      |         |
| connectives          |              |            |      |      |         |
| nesting_condition    |              |            |      |      |         |
| nesting_body         |              |            |      |      |         |
| predicate_2way       |              |            |      |      |         |
| predicate_1way       |              |            |      |      |         |
| predicate_checked    |              |            |      |      |         |
| object_properties    |              |            |      |      |         |
| tuple_whole          |              |            |      |      |         |
| tuple_elements       |              |            |      |      |         |
| tuple_length         |              |            |      |      |         |
| subtyping_nominal    |              |            |      |      |         |
| subtyping_structural |              |            |      |      |         |
| merge_with_union     |              |            |      |      |         |

`V` means passed, `X` means not passed, and `O` means partially passed (always with notes).

## Other Discussions

### refinement invalidation

see issue #7, also see [flow document](https://flow.org/en/docs/lang/refinements/#toc-refinement-invalidations).

### unknown to known length

In Typed Racket, `Listof(T)` has unknown length, while `List(T ...)` has known length. A length test should narrow `Listof` to `List`.

This does not make sense without known length types. Do any migratory languages besides TR have these?

### `predicate_extra_args`

The following is a benchmark item extracted from [an example from mypy](https://mypy.readthedocs.io/en/stable/type_narrowing.html#typeguards-with-parameters). Original code:

``` python
from typing import TypeGuard  # use `typing_extensions` for `python<3.10`

def is_set_of[T](val: set[Any], type: type[T]) -> TypeGuard[set[T]]:
    return all(isinstance(x, type) for x in val)

items: set[Any]
if is_set_of(items, str):
    reveal_type(items)  # set[str]
```

["Official" docs on what type(T) means as an annotation](https://docs.python.org/3/library/typing.html#type-of-class-objects), here argument must be a class. And this pattern works because classes are values and types in Python. It may be impossible in TypeScript because types are erased before runtime.

#### Description

A custom predicate can take extra arguments that are not refined, but helps in refining the type of the variable.

#### Examples

##### Success Expected

TODO: use isinstanceof(x, type(b))

```text
define f(x: Listof(Top), t: Type) -> x is Listof(t):
    return x.all(lambda y: y is t)
```

##### Failure Expected

```text
define f(x: Listof(Top), t: Type) -> x is Listof(t):
    return x.all(lambda y: y is Number) // should not type check
```

### `predicate_multi_args`

This would be a convenient feature to have, but it is not clear if any existing gradual type checker supports this.

#### Description

When a custom predicate is true, the type of the variable is refined to a more specific type with the information that the predicate holds. When a custom predicate is false, the type of the variable is refined to a more specific type with the information that the negation of the predicate holds.

#### Examples

##### Success Expected

```text
define f(x: String | Number, y: String | Number) -> x is String and y is Number:
    return x is String and y is Number

define g(x: String | Number, y: String | Number) -> Number:
    if f(x, y):
        return String.length(x) + y // type of x is refined to String, type of y is refined to Number
    else:
        return 0 // a problem would be that, here we know little about x and y
```

##### Failure Expected

```text
define f(x: String | Number, y: String | Number) -> x is String and y is Number:
    return x is Number and y is String

define g(x: String | Number, y: String | Number) -> Number:
    if f(x, y):
        return String.length(x) + y // type of x is refined to Number, type of y is refined to String
    else:
        return 0
```

## Acknowledge

Thanks to Eric Traut for pointing out [an issue concerning narrowing and subclass of primitive types in Python](https://github.com/microsoft/pyright/issues/9395).
