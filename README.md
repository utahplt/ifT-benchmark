# ot-benchmark

Benchmark for Occurrence Typing (and Similar Techniques).

On what is Occurrence Typing, check the following paper

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

and also [Typed Racket Guide on Occurrence Typing](https://docs.racket-lang.org/ts-guide/occurrence-typing.html).

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->

## Table of Contents

  - [The Benchmark](#the-benchmark)
  - [Benchmark Results](#benchmark-results)

<!-- markdown-toc end -->

## Examples

For a set of code examples that demonstrate the features of occurrence typing, see [Examples.md](Examples.md)

## The Benchmark

From the examples, we can summarize the common features or "API"s that one would expect from a gradual type checker that supports occurrence typing. Each feature, with a brief description, the guarantee it provides, and the examples that demonstrate it, forms a benchmark item. All the benchmark items are listed below.

### `refine_true`

#### Description

Refine the type of a variable when a predicate is true.

#### Guarantee

If the predicate is true, the type of the variable is refined to a more specific type with the information that the predicate holds.

#### Examples

##### Success Expected

```text
define f(x: Any) -> Any:
    if x is String:
        return String.length(x) // type of x is refined to String
    else:
        return x
```

##### Failure Expected

```text
define f(x: Any) -> Any:
    if x is String:
        return x + 1 // type of x is refined to String, adding a number to a string is not allowed
    else:
        return x
```

### `refine_false`

#### Description

Refine the type of a variable when a predicate is false.

#### Guarantee

If the predicate is false, the type of the variable is refined to a more specific type with the information that the negation of the predicate holds.

#### Examples

##### Success Expected

```text
define f(x: String | Number) -> Number:
    if x is String:
        return String.length(x)
    else:
        return x // type of x is refined to Number, namely (String | Number) - String
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

Track test results assigned to variables.

#### Guarantee

When the result of a predicate test is bound to an immutable variable, that variable can also be used as a type guard. When the result of a predicate test is bound to a mutable variable, that variable can be used as a type guard only if it is not updated.

#### Examples

##### Success Expected

```text
define f(x: Any) -> Any:
    let y = x is String
    if y:
        return String.length(x) // type of x is refined to String
    else:
        return x
```

##### Failure Expected

```text
define f(x: Any) -> Any:
    let y = x is String
    if y:
        return x + 1 // type of x is refined to String, adding a number to a string is not allowed
    else:
        return x
```

```text
define f(x: Any) -> Any:
    var y = x is String // y is mutable
    y = true
    if y:
        return String.length(x) // since y is updated, type of x is not refined
    else:
        return x
```

### `connectives`

#### Description

Handle logic connectives, such as `and`, `or`, and `not`.

#### Guarantee

When a predicate is a conjunction of multiple predicates, the type of the variable is refined to the intersection of the types refined by each predicate. When a predicate is a disjunction of multiple predicates, the type of the variable is refined to the union of the types refined by each predicate. When a predicate is a negation of another predicate, the type of the variable is refined to the complement of the type refined by the negated predicate.

#### Examples

##### Success Expected

```text
define f(x: String | Number) -> Number:
    if not (x is Number):
        return String.length(x)
    else:
        return 0

define g(x: Any) -> Number:
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

define g(x: Any) -> Number:
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

Handle nested conditionals with nesting happening in the body.

#### Guarantee

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
    if x is String:
        if x is Number:
            return x + 1 // type of x is empty / bottom type, thus not allowing any operation
        else:
            return 0
    else:
        return 0
```

### `nesting_condition`

#### Description

Handle nested conditionals with nesting happening in the condition.

#### Guarantee

When a conditional statement is nested inside the condition of another conditional statement, the type of the variable is refined to the intersection of the types refined by each conditional statement.

#### Examples

##### Success Expected

```text
define f(x: Any, y: Any) -> Number:
    if (if x is Number: y is String else: false)
        x + String.length(y) // type of x is refined to Number, type of y is refined to String
    else
        0
```

##### Failure Expected

```text
define f(x: Any, y: Any) -> Number:
    if (if x is Number: y is String else: y is String)
        x + String.length(y) // type of x is not clear here, thus not allowing addition
    else
        0
```

### `predicate_2way`

#### Description

Custom predicates refine both positively and negatively.

#### Guarantee

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
    return x is Number

define g(x: String | Number) -> Number:
    if f(x):
        return x + 1 // type of x is refined to String, adding a number to a string is not allowed
    else:
        return x // type of x is refined to Number, namely (String | Number) - String
```

### `predicate_1way`

#### Description

Custom predicates refine only positively. This can be used to model predicates that are not total.

#### Guarantee

When a custom predicate is true, the type of the variable is refined to a more specific type with the information that the predicate holds. When a custom predicate is false, the type of the variable is not refined.

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
        return x // type of x is not refined, thus not compatible with the return type
```

### `predicate_strict`

#### Description

Perform strict type checks on custom predicates.

#### Guarantee

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

### `predicate_loose`

#### Description

Do not perform strict type checks on custom predicates. This can be used in some cases where the type checker is not able to infer the type of the variable, yet the programmer is sure about the type.

#### Guarantee

The type checker does not check that the assertion made by a custom predicate is compatible with the type of the variable, instead just accepting what the programmer asserts.

#### Examples

##### Success Expected

```text
define f(x: Listof(String | Number)) -> assert x is Listof(Number):
    return true // bad example, but should type check

define g(x: Listof(String | Number)) -> Number:
    if f(x):
        return x[0]
    else:
        return 0
```

##### Failure Expected

```text
define f(x: Listof(String | Number)) -> assert x is Listof(Number):
    return true

define g(x: Listof(String | Number)) -> String:
    if f(x):
        return x[0] // type of x is refined to Listof(Number)
    else:
        return 0
```

### `predicate_multi_args`

#### Description

Predicates can refine on more than one arguments.

#### Guarantee

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

### `predicate_extra_args`

#### Description

Predicates can take extra args (not being refined).

#### Guarantee

A custom predicate can take extra arguments that are not refined, but helps in refining the type of the variable.

#### Examples

##### Success Expected

TODO: come up with an example that do not rely on other features or extra features

``` text
define f(x: Pairof(Any, Any), b: Boolean) -> case->
 (-> _ #true A)
 (-> _ #false B)
```

##### Failure Expected

TODO: come up with an example that do not rely on other features or extra features

### `object_properties`

#### Description

Refine types of properties of objects.

#### Guarantee

Partially refine the type of objects, that is, when the predicate is applied to an object property, refine the type of the object property.

#### Examples

##### Success Expected

```text
struct Apple:
    a: Any

define f(x: Apple) -> Number:
    if x.a is Number:
        return x.a // type of x.a is refined to Number
    else:
        return 0
```

##### Failure Expected

```text
struct Apple:
    a: Any

define f(x: Apple) -> Number:
    if x.a is String:
        return x.a // type of x.a is refined to String, thus not allowing the return
    else:
        return 0
```

### `tuple_whole`

#### Description

Refine types of the whole tuple.

#### Guarantee

When appropriate predicates are applied to the whole tuple, refine the type of the whole tuple. Note that the type of a tuple usually include both the type of the elements and the length of the tuple.

#### Examples

##### Success Expected

```text
define f(x: Any) -> Number:
    if x is Tupleof(Number, Number):
        return x[0] + x[1] // type of x is refined to Tupleof(Number, Number)
    else:
        return 0
```

##### Failure Expected

```text
define f(x: Any) -> Number:
    if x is Tupleof(Number, Number):
        return x[0] + x[1] + x[2] // type of x is refined to Tupleof(Number, Number), thus no third element
    else:
        return 0
```

### `tuple_elements`

#### Description

Refine types of single tuple elements, that is, partially refine the type of the tuple.

#### Guarantee

When appropriate predicates are applied to the elements of a tuple, refine the type of the elements of the tuple.

#### Examples

##### Success Expected

```text
define f(x: Tuple(Any, Any)) -> Number:
    if x[0] is Number:
        return x[0] // type of x[0] is refined to Number, type of x is refined to Tuple(Number, Any)
    else:
        return 0
```

##### Failure Expected

``` text
define f(x: Tuple(Any, Any)) -> Number:
    if x[0] is Number:
        return x[0] + x[1] // type of x[0] is refined to Number, but type of x[1] is not clear
    else:
        return 0
```

### `tuple_length`

#### Description

Refine union of tuple types by their length.

#### Guarantee

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

Refine types with nominal subtyping.

#### Guarantee

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

Refine types with structural subtyping.

#### Guarantee

Refine supertypes to subtypes in a structural subtyping scheme.

#### Examples

##### Success Expected

```text
define f(x: Any) -> String:
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

define g(f: Any -> String | Boolean) -> String:
    if f(0) is String:
        return f(0) // type of f(0) is refined to String
    else:
        return "world"

g(f) // this should not type check
```

### `merge_with_union`

#### Description

Merge several types with union instead of joining.

#### Guarantee

When multiple branches where the type of a variable is refined to different types are merged, the type of the variable is refined to the union of the types refined by each branch, instead of joining the types, that is, taking the common supertype.

#### Examples

##### Success Expected

```text
define f(x: Any) -> String | Number:
    if x is String:
        String.append(x, "hello") // type of x is refined to String
    else if x is Number:
        x = x + 1 // type of x is refined to Number
    else:
        return 0
    return x // type of x is refined to String | Number; a bad implementation will refine to Any
```

##### Failure Expected

```text
define f(x: Any) -> String | Number:
    if x is String:
        String.append(x, "hello") // type of x is refined to String
    else if x is Number:
        x = x + 1 // type of x is refined to Number
    else:
        return 0
    return x + 1 // type of x is refined to String | Number
```

| Benchmark            | Description                                              |
|:---------------------|----------------------------------------------------------|
| positive             | refine when condition is true                            |
| negative             | refine when condition is false                           |
| alias                | track test results assigned to variables                 |
| connectives          | handle logic connectives                                 |
| nesting_condition    | nested conditionals with nesting happening in condition  |
| nesting_body         | nested conditionals with nesting happening in body       |
| predicate_2way       | custom predicates refines both positively and negatively |
| predicate_1way       | custom predicates refines only positively                |
| predicate_strict     | perform strict type checks on custom predicates          |
| predicate_loose      | do not perform strict type checks on custom predicates   |
| predicate_multi_args | predicates can refine on more than one arguments         |
| predicate_extra_args | predicates can take extra args (not being refined)       |
| object_properties    | refine types of properties of objects                    |
| tuple_whole          | refine types of the whole tuple                          |
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
| predicate_strict     |              |            |      |      |         |
| predicate_loose      |              |            |      |      |         |
| predicate_multi_args |              |            |      |      |         |
| predicate_extra_args |              |            |      |      |         |
| object_properties    |              |            |      |      |         |
| tuple_whole          |              |            |      |      |         |
| tuple_elements       |              |            |      |      |         |
| tuple_length         |              |            |      |      |         |
| subtyping_nominal    |              |            |      |      |         |
| subtyping_structural |              |            |      |      |         |
| merge_with_union     |              |            |      |      |         |

`●` means passed, `○` means not passed, and `◉` means partially passed (always with notes).

## Other Discusstions

### refinement invalidation

see issue #7, also see [flow document](https://flow.org/en/docs/lang/refinements/#toc-refinement-invalidations).
