Typed Clojure
===

Typed Clojure is a gradual type system for Clojure, providing static type checking for a dynamically typed language.

* Language resources:
  - <https://github.com/typedclojure/typedclojure>
  - <https://typedclojure.org/>
* If-T version: **1.0**
* Implementation: [./main.clj](./main.clj), [./examples.clj](./examples.clj)
* Raw command to run the benchmark: `clj -M:typed/check <path-to-file>`

#### Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the dynamic type? If these types do not exist, explain the alternatives.

* **Top**: `t/Any` — Represents any possible value in Clojure, analogous to Clojure's dynamic typing.
* **Bottom**: `t/Nothing` — Represents the absence of any value (uninhabited type), used for functions that never return or always throw.
* **Dynamic**: `t/Any` — Serves as the dynamic type, allowing any value without type checking restrictions, effectively disabling static type checking for that expression.

Typed Clojure uses `t/Any` for both top and dynamic types, as Clojure's dynamic nature means most untyped code implicitly operates at this level. `t/Nothing` is rarely used explicitly but exists for type system completeness.

> Q. What base types does this implementation use? Why?

* `t/Str` (String)
* `t/Num` (Number, including integers and floating-point)
* `t/Bool` (Boolean)
* `t/Int` (Integer, a subtype of `t/Num`)
* `t/Double` (Double-precision floating-point, a subtype of `t/Num`)

These types correspond to Clojure's core data types, which are immutable and commonly used in functional programming. They are chosen to align with Clojure's runtime type system, enabling precise type narrowing for common predicates like `string?`, `number?`, and `boolean?`.

> Q. What container types does this implementation use (for objects, tuples, etc)? Why?

* **Objects**: `t/HMap` (Heterogeneous Map) — Represents maps with specific keys and value types, e.g., `(t/HMap :mandatory {:a (t/U nil Number)} :complete? true)`. Used for struct-like data with known fields.
* **Tuples**: `t/NonEmptyVec` (Non-empty Vector) and `t/Vec` (Vector) — Represent sequences with specific element types, used for tuple-like structures. Vectors are Clojure's primary sequence type, and `t/NonEmptyVec` ensures at least one element.
* **Sequences**: `t/Seqable` — Represents any sequence (lists, vectors, etc.), used for recursive structures like trees.

These types reflect Clojure's immutable data structures, which are central to its functional paradigm. `t/HMap` is used for structs because Clojure maps are commonly used for key-value data. Vectors are used for tuples due to their indexed access and immutability, which supports type narrowing on elements.

#### Type Narrowing

> Q. How do simple type tests work in this language?

Type tests in Typed Clojure use Clojure's built-in predicates like `string?`, `number?`, `boolean?`, etc., which return a boolean indicating whether a value matches a type. These predicates are recognized by Typed Clojure's occurrence typing system, which refines the type of a variable based on the predicate's result in conditional branches.

Example:
```clojure
(if (string? x)
  (count x) ; x is refined to t/Str
  x)        ; x is refined to (t/I t/Any (t/Not t/Str))
```

> Q. Are there other forms of type test? If so, explain.

Typed Clojure supports custom predicates via annotations like `(t/Pred Type)` and filter annotations (`:filters {:then ... :else ...}`). These allow user-defined functions to act as type tests, refining types in both positive (`:then`) and negative (`:else`) branches.

Example:
```clojure
(t/ann my-pred [(t/U t/Str t/Num) -> t/Bool :filters {:then (is t/Str 0) :else (! t/Str 0)}])
(defn my-pred [x] (string? x))
```

Additionally, Typed Clojure supports structural checks (e.g., `vector?`, `map?`) and length checks (e.g., `count`) for refining sequence types, as seen in `tuple_length`.

> Q. How do type casts work in this language?

Type casts in Typed Clojure are performed using `t/ann-form`, which asserts that an expression has a specific type. Unlike dynamic casts, `t/ann-form` is purely for the type checker and does not affect runtime behavior. If the asserted type is incorrect, the type checker will flag an error if it can detect the mismatch.

Example:
```clojure
(t/ann-form x t/Num) ; Asserts x is a t/Num
```

> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Symmetric predicates use the `:filters` annotation with `:then` and `:else` clauses to specify type refinements for both branches.

Example:
```clojure
(t/ann predicate-2way-success-f [(t/U t/Str t/Num) -> t/Bool
                                 :filters {:then (is t/Str 0) :else (! t/Str 0)}])
(defn predicate-2way-success-f [x]
  (string? x))
```
Here, `:then (is t/Str 0)` refines `x` to `t/Str` when the predicate is true, and `:else (! t/Str 0)` refines `x` to `(t/Not t/Str)` (i.e., `t/Num`) when false.

> Q. If the language supports other type-narrowing predicates, describe them below.

Typed Clojure supports 1-way predicates, which refine types only in the positive (`:then`) branch, leaving the negative branch unrefined. This is useful for underapproximations, like checking if a number is positive.

Example:
```clojure
(t/ann predicate-1way-success-f [(t/U t/Str t/Num) -> t/Bool :filters {:then (is t/Num 0)}])
(defn predicate-1way-success-f [x]
  (and (number? x) (> x 0)))
```

#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

All benchmarks are expressible in Typed Clojure, as shown in `main.clj`. The language's flexible type system, based on occurrence typing and union types, supports all the required constructs (e.g., `positive`, `negative`, `connectives`, etc.). The implementation closely mirrors the pseudocode in `readme.md`.

> Q. Are any benchmarks expressed particularly well, or particularly poorly? Explain.

Expressed Well:
- `positive`, `negative`, `connectives`: These are straightforward, as Typed Clojure's occurrence typing directly supports refining types based on predicates like `string?` and logical connectives (`and`, `or`, `not`). The syntax is concise and aligns with Clojure's functional style.
- `predicate_2way`, `predicate_1way`, `predicate_checked`: Typed Clojure's `:filters` annotation is designed for custom predicates, making these benchmarks natural to express. The explicit `:then` and `:else` filters clearly specify type refinements.
- `struct_fields`, `tuple_elements`: `t/HMap` and `t/NonEmptyVec` map well to Clojure's map and vector data structures, allowing precise type narrowing on fields and elements.

Expressed Poorly:
- `tuple_length`: While expressible, length-based narrowing requires explicit checks with count, and the type system must infer the correct tuple type from a union. This can feel verbose compared to languages with native tuple length types (e.g., TypeScript's tuple types).
- `nesting_condition`: Nested conditionals are supported, but the syntax can become complex when combining multiple predicates, requiring careful annotation to ensure type refinements propagate correctly.

> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

The implementation in `main.clj` is very direct compared to the pseudocode in `readme.md`. Typed Clojure's syntax for predicates, conditionals, and type annotations closely mirrors the pseudocode's structure. For example:

- `positive` maps directly to `if` with `string?` checks and `count` operations.
- `merge_with-union` uses Clojure's `cond` to express multiple branches, aligning with the pseudocode's `if-else` chains.
- Custom predicates use `:filters`, which are a natural extension of the pseudocode's `x is T` syntax.

The main complexity arises in verbose annotations for complex types (e.g., `t/HMap`, `t/NonEmptyVec`), but these are necessary for precision and do not deviate significantly from the pseudocode's intent.

#### Advanced Examples

> Q. Are any examples inexpressible? Why?

All examples in `examples.clj` are expressible, but `tree_node` in the failure case passes type checking incorrectly. This is because Typed Clojure does not fully verify the body of custom predicates like `tree-node?` against their declared type (`t/Pred TreeNode`), trusting the programmer's annotation. This is a known limitation, as noted in the benchmark results table (`tree_node` marked as `X`).

> Q. Are any examples expressed particularly well, or particularly poorly? Explain.

Expressed Well:
- `filter`: The filter-success function uses filterv, which is idiomatic in Clojure and aligns with the type annotation `(t/All [A] [(t/Vec A) [A :-> t/Bool] :-> (t/Vec A)])`. The type variable A ensures genericity, and the implementation is concise.
- flatten: The recursive `flatten-success` function leverages Clojure's sequence operations (`first`, `next`, `into`) and type annotations (`t/Seqable`, `t/Ve`c) to clearly express the tree-to-vector transformation. The use of `t/ann-form` for type assertions in base cases is natural.
- rainfall: The rainfall-success function uses a typed loop (`t/loop`) to process weather reports, with clear annotations for `t/Double` and `t/Long`. The implementation closely follows Clojure's functional style, making it idiomatic and precise.

Expressed Poorly:
- `tree_node`: The `tree-node?` predicate is verbose due to the recursive type `TreeNode` and the need to check vector structure, element types, and recursive application of `every?`. The failure case passes incorrectly because Typed Clojure does not validate the predicate body, making it less robust than desired.

> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

The implementations in examples.clj are direct but slightly more verbose due to explicit type annotations. For example:

- `filter` maps directly to the pseudocode's filtering logic but requires a polymorphic type annotation `(t/All [A] ...)`.
- `flatten` follows the pseudocode's recursive structure but needs `t/ann-form` for base cases to assert types like `IntVector`.
- `rainfall` aligns closely with the pseudocode but includes additional checks (e.g., `map?`, `not (nil? day)`) to handle Clojure's dynamic nature, making it slightly more complex.
- `tree_node` is direct but requires multiple nested checks, and the lack of predicate body validation introduces a subtle error in the failure case.
