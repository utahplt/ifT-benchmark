# Benchmark for Occurrence Typing (and Similar Techniques)

Start with examples from ICFP'10 paper.

## Examples from ICFP'10 paper

### Example 1

```scheme
(if (number? x) (add1 x) 0)
```

> Regardless of the value of _x_, this program fragment always produces a number. Thus, our type system should accept this fragment, regardless of the type assigned to _x_, even if the type is not legitimate for _add1_. The key to typing this program is to assign the second occurrence of _x_ a different, more precise type than it has in the outer context. Fortunately, we know that for any value of type **Number**, _number?_ returns **#t**; otherwise, it returns **#f**. Therefore, it is safe to use **Number** as the type of _x_ in the then branch.

Key points: _x_ should have type **Number** in the _then_ branch regardless of its type in the outer context; its type in the _else_ branch is not mentioned in this example.

### Example 2
The following function f always produces a number:
```scheme
(define: (f [x : (⋃ String Number)])
  (if (number? x) (add1 x) (string-length x)))
```
> If _(number? x)_ produces **#t**, _x_ is an appropriate input for _add1_. If it produces **#f**, _x_ must be a **String** by process of elimination; it is therefore an acceptable input to _string-length_. To handle this program, the type system must take into account not only when predicates hold, but also when they fail to hold.

Key points: The type system must be able to reason about the negation of a predicate, and apply this information to the _else_ branch.

### Example 3

```scheme
... (let ([x (member v l)]) 
      (if x  
          — compute with x —
          (error ’fail))) ...
```

> This idiom, seen here in _member_, uses arbitrary non-**#f** values as true and uses **#f** as a marker for missing results, analogous to ML’s `NONE`. The type for _member_ specifies this behavior with an appropriate type signature. It can thus infer that in the _then_ branch, _x_ has the type of the desired result and is not **#f**.

Key points: Being able to reason about `let`-bindings.

### Example 4

> Logical connectives can combine the results of predicates:

```scheme
... (if (or (number? x) (string? x)) (f x) 0) ...
```

> For this fragment to typecheck, the type system must recognize that (**or** (_number?_ _x_) (_string?_ _x_)) ensures that _x_ has type (⋃ **String** **Number**) in the _then_ branch, the domain of _f_ from example 2.

Key points: Being able to reason about logical connectives, _or_ in this case indicates that _x_ has a union type.

### Example 5
> For and, there is no such neat connection:

```scheme
... (if (and (number? x) (string? y)) 
        (+ x (string-length y))
        0) ...
```

> Example 5 is perfectly safe, regardless of the values of x and y.

Key points: Being able to reason about logical connectives, _and_ in this case indicates the type of _x_ and _y_ in the same time. Worth noting that this and the previous example both focus on the _then_ branch only.

### Example 6
> In contrast, the next example shows how little we know when a conjunction evaluates to false:

```scheme
;; x is either a Number or a String
... (if (and (number? x) (string? y)) 
        (+ x (string-length y)) 
        (string-length x)) ...
```

> Here a programmer falsely assumes _x_ to be a **String** when the test fails. But, the test may produce **#f** because _x_ is actually a **String**, or because _y_ is not a **String** while _x_ is a **Number**. In the latter case, (_string-length_ _x_) fails. In general, when a conjunction is false, we do not know which conjunct is false.

Key points: First note that this example is not safe (i.e. a failing example). It points out that the ability to handle the _else_ branch is important. However, the negation of a conjunction is not so informative.

### Example 7

> Finally, and is expressible using nested _if_ expressions, a pattern that is often macro-generated:

```scheme
... (if (if (number? x) (string? y) #f)
        (+ x (string-length y)) 
        0) ...
```

> One way for the type system to deal with this pattern is to reason that it is equivalent to the conjunction of the two predicates.

Key points: Being able to reason about nested if expressions, which can be seen as a way to express logical connectives.

### Example 8
> So far, we have seen how programmers can use predefined predicates. It is important, however, that programmers can also abstract over existing predicates:

```scheme
(define: (strnum? [x : ⊤]) ;; ⊤ is the top type 
  (or (string? x) (number? x)))
```

> Take the previous example of a test for (⋃ **String** **Number**). A programmer can use the test to create the function _strnum?_, which behaves as a predicate for that type. This means the type system must represent the fact that _strnum?_ is a predicate for this type, so that it can be exploited for conditionals.

Key points: The ability to let users define their own predicates.

### Example 9
> In example 4, we saw the use of _or_ to test for disjunctions. Like _and_, _or_ is directly expressible using _if_:

```scheme
(if (let ([tmp (number? x)]) 
      (if tmp tmp (string? x)))
    (f x) 
    0)
```

> The expansion is analyzed as follows: if (_number?_ _x_) is **#t**, then so is _tmp_, and thus the result of the inner _if_ is also **#t**. Otherwise, the result of the inner _if_ is (_string?_ _x_). This code presents a new challenge for the type system, however. Since the expression tested in the inner _if_ is the variable reference _tmp_, but the system must also learn about (_number?_ _x_) from the test of _tmp_.

Key points: This example shows that the semantics of _or_ can also be expressed through combination of reasoning about _if_ and _let_.

### Example 10 (Selectors)
> All of the tests thus far only involve variables. It is also useful to subject the result of arbitrary expressions to type tests:

```scheme
... (if (number? (car p)) (add1 (car p)) 7) ...
```

> Even if _p_ has the pair type 〈⊤, ⊤〉, then example 10 should produce a number. Of course, simply accommodating repeated applications of _car_ is insufficient for real programs. Instead, the relevant portions of the type of _p_ must be refined in the _then_ and _else_ branches of the _if_.

Key points: The ability to refine the type of parts of compound objects.

### Example 11 (Selectors)

```scheme
(λ: ([p : 〈⊤, ⊤〉]) 
  (if (and (number? (car p)) (number? (cdr p))) 
    (g p) 
    'no))
```

> The test expression refines the type of _p_ from the declared 〈⊤, ⊤〉 to the required 〈**Number**, **Number**〉. This is the expected result of the conjunction of tests on the _car_ and _cdr_ fields.

Key points: The same as the previous example.

### Example 12 (Selectors)
> Example 12 shows how programmers can simultaneously abstract over the use of both predicates and selectors:

```scheme
(define carnum? 
  (λ: ([x : 〈⊤, ⊤〉]) (number? (car x))))
```

> The _carnum?_ predicate tests if the _car_ of its argument is a **Number**, and its type must capture this fact.

Key points: This example combines the ability to define predicates and refine the type of parts of compound objects.

### Example 13 (Reasoning Logically)

> Of course, we do learn something when conjunctions such as those in examples 5 and 6 are false. When a conjunction is false, we know that one of the conjuncts is false, and thus when all but one are true, the remaining one must be false. This reasoning principle is used in multi-way conditionals, which is a common idiom extensively illustrated in _How to Design Programs_ [Felleisen et al. 2001]:

```scheme
... (cond
      [(and (number? x) (string? y)) — 1 —]
      [(number? x) — 2 —] 
      [else — 3 —]) ...
```

> This program represents a common idiom. In clause 1, we obviously know that _x_ is a **Number** and _y_ is a **String**. In clause 2, _x_ is again a **Number**. But we also know that _y_ cannot be a **String**. To effectively typecheck such programs, the type system must be able to follow this reasoning.

Key points: The ability to reason about logical connectives and multi-way conditionals: latter branches imply negations of previous branches.

### Example 14 (Putting It All Together)
> Our type system correctly handles all of the preceding examples. Finally, we combine these features into an example that demonstrates all aspects of our system:

```scheme
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

## Extracted Key Features from the Examples
1. Being able to refine types using predicates, and show it in the _then_ branch of an _if_ expression. (Example 1)
2. Being able to reason about the negation of the predicate, and show this information in the _else_ branch of an _if_ expression. (Examples 2, 6)
3. Being able to reason about `let`-bindings, i.e. aliases of variables. (Examples 3, 9)
4. Being able to reason about logical connectives; for example, _or_ indicates a union type, _and_ indicates a conjunction of types. (Examples 4, 5)
5. Support nested _if_ expressions; logical connectives can be implemented in this way. (Examples 7, 9)
6. Support user-defined predicates. (Examples 8, 12)
7. Support refinement of types of parts of compound objects. (Examples 10, 11, 12)
8. Extend the above to multi-way conditionals. (Example 13)