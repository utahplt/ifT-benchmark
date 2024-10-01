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

  - [Start with Examples from ICFP'10 Paper](#start-with-examples-from-icfp10-paper)
    - [Extracted Key Features from the Examples](#extracted-key-features-from-the-examples)
    - [Examples from ICFP'10 paper](#examples-from-icfp10-paper)
      - [Example 1](#example-1)
      - [Example 2](#example-2)
      - [Example 3](#example-3)
      - [Example 4](#example-4)
      - [Example 5](#example-5)
      - [Example 6](#example-6)
      - [Example 7](#example-7)
      - [Example 8](#example-8)
      - [Example 9](#example-9)
      - [Example 10 (Selectors)](#example-10-selectors)
      - [Example 11 (Selectors)](#example-11-selectors)
      - [Example 12 (Selectors)](#example-12-selectors)
      - [Example 13 (Reasoning Logically)](#example-13-reasoning-logically)
      - [Example 14 (Putting It All Together)](#example-14-putting-it-all-together)
    - [More examples](#more-examples)
      - [Example 15 (Unions vs Joins)](#example-15-unions-vs-joins)
  - [The Benchmark](#the-benchmark)
  - [Benchmark Results](#benchmark-results)

<!-- markdown-toc end -->


## Start with Examples from ICFP'10 Paper

Those examples describe what a language that implements Occurrence Typing should be able to do.

### Extracted Key Features from the Examples

1.  Being able to refine types using predicates, and show it in the _then_ branch of an _if_ expression. (Example 1)
2.  Being able to reason about the negation of the predicate, and show this information in the _else_ branch of an _if_ expression. (Examples 2, 6)
3.  Being able to reason about `let`-bindings, i.e. aliases of variables. (Examples 3, 9)
4.  Being able to reason about logical connectives; for example, _or_ indicates a union type, _and_ indicates a conjunction of types. (Examples 4, 5)
5.  Support nested _if_ expressions; logical connectives can be implemented in this way. (Examples 7, 9)
6.  Support user-defined predicates. (Examples 8, 12)
7.  Support refinement of types of parts of compound objects. (Examples 10, 11, 12)
8.  Merge types into union types, not joint types. (Examples 15)

~8.  Extend the above to multi-way conditionals. (Example 13)~ (can encode `cond` with support for `if` (key features 1 and 5))

For more details for each example, check the section below. Quoted content are from the paper.

### Examples from ICFP'10 paper

#### Example 1

```racket
(if (number? x) (add1 x) 0)
```

> Regardless of the value of _x_, this program fragment always produces a number. Thus, our type system should accept this fragment, regardless of the type assigned to _x_, even if the type is not legitimate for _add1_. The key to typing this program is to assign the second occurrence of _x_ a different, more precise type than it has in the outer context. Fortunately, we know that for any value of type **Number**, _number?_ returns **#t**; otherwise, it returns **#f**. Therefore, it is safe to use **Number** as the type of _x_ in the then branch.

Key points: _x_ should have type **Number** in the _then_ branch regardless of its type in the outer context; its type in the _else_ branch is not mentioned in this example.

#### Example 2

The following function f always produces a number:
```racket
(define: (f [x : (⋃ String Number)])
  (if (number? x) (add1 x) (string-length x)))
```
> If _(number? x)_ produces **#t**, _x_ is an appropriate input for _add1_. If it produces **#f**, _x_ must be a **String** by process of elimination; it is therefore an acceptable input to _string-length_. To handle this program, the type system must take into account not only when predicates hold, but also when they fail to hold.

Key points: The type system must be able to reason about the negation of a predicate, and apply this information to the _else_ branch.

#### Example 3

```racket
... (let ([x (member v l)])
      (if x
          — compute with x —
          (error ’fail))) ...
```

> This idiom, seen here in _member_, uses arbitrary non-**#f** values as true and uses **#f** as a marker for missing results, analogous to ML’s `NONE`. The type for _member_ specifies this behavior with an appropriate type signature. It can thus infer that in the _then_ branch, _x_ has the type of the desired result and is not **#f**.

Key points: Being able to reason about `let`-bindings.

#### Example 4

> Logical connectives can combine the results of predicates:

```racket
... (if (or (number? x) (string? x)) (f x) 0) ...
```

> For this fragment to typecheck, the type system must recognize that (**or** (_number?_ _x_) (_string?_ _x_)) ensures that _x_ has type (⋃ **String** **Number**) in the _then_ branch, the domain of _f_ from example 2.

Key points: Being able to reason about logical connectives, _or_ in this case indicates that _x_ has a union type.

#### Example 5

> For and, there is no such neat connection:

```racket
... (if (and (number? x) (string? y))
        (+ x (string-length y))
        0) ...
```

> Example 5 is perfectly safe, regardless of the values of x and y.

Key points: Being able to reason about logical connectives, _and_ in this case indicates the type of _x_ and _y_ in the same time. Worth noting that this and the previous example both focus on the _then_ branch only.

#### Example 6

> In contrast, the next example shows how little we know when a conjunction evaluates to false:

```racket
;; x is either a Number or a String
... (if (and (number? x) (string? y))
        (+ x (string-length y))
        (string-length x)) ...
```

> Here a programmer falsely assumes _x_ to be a **String** when the test fails. But, the test may produce **#f** because _x_ is actually a **String**, or because _y_ is not a **String** while _x_ is a **Number**. In the latter case, (_string-length_ _x_) fails. In general, when a conjunction is false, we do not know which conjunct is false.

Key points: First note that this example is not safe (i.e. a failing example). It points out that the ability to handle the _else_ branch is important. However, the negation of a conjunction is not so informative.

#### Example 7

> Finally, and is expressible using nested _if_ expressions, a pattern that is often macro-generated:

```racket
... (if (if (number? x) (string? y) #f)
        (+ x (string-length y))
        0) ...
```

> One way for the type system to deal with this pattern is to reason that it is equivalent to the conjunction of the two predicates.

Key points: Being able to reason about nested if expressions, which can be seen as a way to express logical connectives.

#### Example 8

> So far, we have seen how programmers can use predefined predicates. It is important, however, that programmers can also abstract over existing predicates:

```racket
(define: (strnum? [x : ⊤]) ;; ⊤ is the top type
  (or (string? x) (number? x)))
```

> Take the previous example of a test for (⋃ **String** **Number**). A programmer can use the test to create the function _strnum?_, which behaves as a predicate for that type. This means the type system must represent the fact that _strnum?_ is a predicate for this type, so that it can be exploited for conditionals.

Key points: The ability to let users define their own predicates.

#### Example 9

> In example 4, we saw the use of _or_ to test for disjunctions. Like _and_, _or_ is directly expressible using _if_:

```racket
(if (let ([tmp (number? x)])
      (if tmp tmp (string? x)))
    (f x)
    0)
```

> The expansion is analyzed as follows: if (_number?_ _x_) is **#t**, then so is _tmp_, and thus the result of the inner _if_ is also **#t**. Otherwise, the result of the inner _if_ is (_string?_ _x_). This code presents a new challenge for the type system, however. Since the expression tested in the inner _if_ is the variable reference _tmp_, but the system must also learn about (_number?_ _x_) from the test of _tmp_.

Key points: This example shows that the semantics of _or_ can also be expressed through combination of reasoning about _if_ and _let_.

#### Example 10 (Selectors)

> All of the tests thus far only involve variables. It is also useful to subject the result of arbitrary expressions to type tests:

```racket
... (if (number? (car p)) (add1 (car p)) 7) ...
```

> Even if _p_ has the pair type 〈⊤, ⊤〉, then example 10 should produce a number. Of course, simply accommodating repeated applications of _car_ is insufficient for real programs. Instead, the relevant portions of the type of _p_ must be refined in the _then_ and _else_ branches of the _if_.

Key points: The ability to refine the type of parts of compound objects.

#### Example 11 (Selectors)

```racket
(λ: ([p : 〈⊤, ⊤〉])
  (if (and (number? (car p)) (number? (cdr p)))
    (g p)
    'no))
```

> The test expression refines the type of _p_ from the declared 〈⊤, ⊤〉 to the required 〈**Number**, **Number**〉. This is the expected result of the conjunction of tests on the _car_ and _cdr_ fields.

Key points: The same as the previous example.

#### Example 12 (Selectors)

> Example 12 shows how programmers can simultaneously abstract over the use of both predicates and selectors:

```racket
(define carnum?
  (λ: ([x : 〈⊤, ⊤〉]) (number? (car x))))
```

> The _carnum?_ predicate tests if the _car_ of its argument is a **Number**, and its type must capture this fact.

Key points: This example combines the ability to define predicates and refine the type of parts of compound objects.

#### Example 13 (Reasoning Logically)

> Of course, we do learn something when conjunctions such as those in examples 5 and 6 are false. When a conjunction is false, we know that one of the conjuncts is false, and thus when all but one are true, the remaining one must be false. This reasoning principle is used in multi-way conditionals, which is a common idiom extensively illustrated in _How to Design Programs_ [Felleisen et al. 2001]:

```racket
... (cond
      [(and (number? x) (string? y)) — 1 —]
      [(number? x) — 2 —]
      [else — 3 —]) ...
```

> This program represents a common idiom. In clause 1, we obviously know that _x_ is a **Number** and _y_ is a **String**. In clause 2, _x_ is again a **Number**. But we also know that _y_ cannot be a **String**. To effectively typecheck such programs, the type system must be able to follow this reasoning.

Key points: The ability to reason about logical connectives and multi-way conditionals: latter branches imply negations of previous branches.

#### Example 14 (Putting It All Together)

> Our type system correctly handles all of the preceding examples. Finally, we combine these features into an example that demonstrates all aspects of our system:

```racket
(λ: ([input : (⋃ Number String)]
     [extra : 〈⊤, ⊤〉])
  (cond
    [(and (number? input) (number? (car extra)))
     (+ input (car extra))]
    [(number? (car extra))
     (+ (string-length input) (car extra))]
    [else 0]))
```

Key points: This example combines all the features of the system.

### More examples

These are examples that also make difference, but not in the ICFP'10 paper.

#### Example 15 (Unions vs Joins)

Taken from [the document of Pyright](https://microsoft.github.io/pyright/#/mypy-comparison?id=unions-vs-joins).

``` python
def func1(val: object):
    if isinstance(val, str):
        pass
    elif isinstance(val, int):
        pass
    else:
        return
    reveal_type(val) # mypy: object, pyright: str | int

def func2(condition: bool, val1: str, val2: int):
    x = val1 if condition else val2
    reveal_type(x) # mypy: object, pyright: str | int

    y = val1 or val2
    # In this case, mypy uses a union instead of a join
    reveal_type(y) # mypy: str | int, pyright: str | int
```

> When merging two types during code flow analysis or widening types during constraint solving, pyright always uses a union operation. Mypy typically (but not always) uses a “join” operation, which merges types by finding a common supertype. The use of joins discards valuable type information and leads to many false positive errors that are [well documented within the mypy issue tracker](https://github.com/python/mypy/issues?q=is%3Aissue+is%3Aopen+label%3Atopic-join-v-union).

Key points: Merge types with union types, not common supertype.

## The Benchmark

According to the [extracted key features](#extracted-key-features-from-the-examples), the following benchmark items are proposed.

| Benchmark            | Description                                              |
|:---------------------|----------------------------------------------------------|
| positive             | refine when condition is true                            |
| negative             | refine when condition is false                           |
| alias                | track test results assigned to variables                 |
| connectives          | handle logic connectives                                 |
| nesting_condition    | nested conditionals with nesting happening in condition  |
| nesting_body         | nested conditionals with nesting happening in body       |
| custom_predicates    | allow programmers define their own predicates            |
| predicate_2way       | custom predicates refines both positively and negatively |
| predicate_strict     | perform strict type checks on custom predicates          |
| predicate_multi_args | predicates can have more than one arguments              |
| object_properties    | refine types of properties of objects                    |
| tuple_whole          | refine types of the whole tuple                          |
| tuple_elements       | refine types of tuple elements                           |
| subtyping            | refine supertypes to subtypes                            |
| subtyping_structural | refine structural subtyping                              |

(NOTE: it may be better to group some benchmark items and give a x/y looking score for the group)

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
| custom_predicates    |              |            |      |      |         |
| predicate_2way       |              |            |      |      |         |
| predicate_strict     |              |            |      |      |         |
| predicate_multi_args |              |            |      |      |         |
| object_properties    |              |            |      |      |         |
| tuple_whole          |              |            |      |      |         |
| tuple_elements       |              |            |      |      |         |
| subtyping            |              |            |      |      |         |
| subtyping_structural |              |            |      |      |         |
| merge_union          |              |            |      |      |         |

`●` means passed, `○` means not passed, and `◉` means partially passed (always with notes).
