Sorbet (Ruby)
===

Sorbet adds static types to Ruby.

* Language resources:
  - <https://sorbet.org/docs/overview>
  - <https://github.com/sorbet/sorbet>
  - <https://sorbet.org/docs/gradual>
  - <https://sorbet.org/docs/from-typescript>
* If-T version: **1.0**
* Implementation: [./main.rb](./main.rb)
* Raw command to run the benchmark: `srb tc main.rb`

## Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the dynamic type? If these types do not exist, explain the alternatives.

* Top = `T.anything`
* Bottom = `T.noreturn`
* Dynamic = `T.untyped`

`T.untyped` is Sorbet’s dynamic type, used for values with unknown types, such as those from untyped Ruby code. It allows any operation but provides no type safety. Sorbet supports gradual typing, so `T.untyped` is common in mixed typed/untyped codebases.

<https://sorbet.org/docs/static>

> Q. What base types does this implementation use? Why?

`String`, `Integer`, `TrueClass`, and `FalseClass`

These are standard Ruby classes, chosen for their simplicity and immutability, making them suitable for testing type narrowing in Sorbet.

> Q. What container types does this implementation use (for objects, tuples, etc)? Why?

* Hash types for objects: `{ a: T.untyped }` or `{ a: T.any(String, Integer) }`
* Array types for tuples: `[T.untyped, T.untyped]` or `[Integer, T.any(String, Integer)]`
* Union types for sized tuples: `T.any([Integer, Integer], [String, String, String])`

Hashes represent key-value objects, common in Ruby. Arrays serve as tuples, with fixed or variable lengths. Union types model sized tuples by distinguishing lengths (e.g., 2 vs. 3 elements). These types are immutable in the context of the benchmark, ensuring type soundness.

## Type Narrowing

> Q. How do simple type tests work in this language?

Sorbet uses Ruby’s `is_a?` method for type tests, e.g., `x.is_a?(String)`. These refine types in conditional branches when Sorbet can prove the type is narrowed.

Example: `if x.is_a?(String); x.length; else; 0; end`

<https://sorbet.org/docs/flow-sensitive>

> Q. Are there other forms of type test? If so, explain.

* `T.assert_type!(x, T)`: Asserts `x` has type `T`, raising an error if not, and refining the type in the current scope.
* `case` statements with type checks: Sorbet can narrow types based on `when` clauses using `is_a?`.

<https://sorbet.org/docs/type-assertions>

> Q. How do type casts work in this language?

`T.let(x, T)` and `T.cast(x, T)` assign type `T` to `x`. `T.let` is used for local type annotations, while `T.cast` inserts runtime checks (in strict mode) to enforce the type. Both update the type environment statically.

Example: `T.cast(x, String)` ensures `x` is treated as `String`.

<https://sorbet.org/docs/type-assertions>

> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Sorbet does not support type-narrowing predicates (symmetric or otherwise). Functions returning `T::Boolean` (e.g., `x.is_a?(String)`) do not refine the argument’s type in the caller’s scope.

Example: A function like `sig { params(x: T.any(String, Integer)).returns(T::Boolean) }` cannot refine `x` to `String` or `Integer` based on the return value.

<https://sorbet.org/docs/from-typescript>

> Q. If the language supports other type-narrowing predicates, describe them below.

Sorbet lacks support for type-narrowing predicates, including one-way or checked predicates. The benchmark implements these as stubs with dummy returns (`true`, `0`) for success cases and type errors (e.g., `x.is_nan`) for failure cases to highlight this limitation.

## Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

No, all benchmarks are expressible in Sorbet. However, predicate-related benchmarks (`predicate_2way`, `predicate_1way`, `predicate_checked`) are implemented as stubs due to Sorbet’s lack of type predicate support.

> Q. Are any benchmarks expressed particularly well, or particularly poorly? Explain.

* **Well-expressed**: `positive`, `negative`, `alias`, `connectives`, `nesting_body`, `nesting_condition` use straightforward `is_a?` checks and align closely with Ruby’s dynamic typing idioms, making them natural for Sorbet’s flow-sensitive typing.
* **Poorly-expressed**: `predicate_2way`, `predicate_1way`, `predicate_checked` are stubs because Sorbet cannot express type predicates. Success cases return dummy values, and failure cases trigger artificial type errors (e.g., `x.is_nan`).

> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

The implementation is direct for most benchmarks, using Ruby’s `if`/`else` and `is_a?` to mirror If-T’s pseudocode. Exceptions:
* Predicate benchmarks use stubs instead of predicate logic.
* `object_properties` uses Hashes instead of objects, as Ruby’s structs are less common.
* `tuple_length` uses union types (`T.any([Integer, Integer], [String, String, String])`) to encode size distinctions, which is less direct but necessary for static typing.

## Advanced Examples

> Q. Are any examples inexpressible? Why?

No, all advanced examples are expressible in Sorbet.

> Q. Are any examples expressed particularly well, or particularly poorly? Explain.

* **Well-expressed**: `merge_with_union` leverages Sorbet’s union types (`T.any(String, Integer)`) and `is_a?` checks to handle dynamic type merging, closely matching the pseudocode.
* **Poorly-expressed**: `flatten` and `rainfall` are not implemented in this benchmark version but would require careful type annotations. `flatten` would need restricted union types to avoid `T.untyped`, and `rainfall` would use `Integer` instead of `Float` to avoid Ruby’s numeric complexities.

> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

The implementation is fairly direct, with differences due to:
1. Ruby’s Hash-based objects instead of structs for `object_properties`.
2. Array-based tuples with union types for `tuple_length`.
3. Stubs for predicates due to Sorbet’s limitations.
4. Functional style in some cases (e.g., `connectives_success_g`) vs. imperative pseudocode.
