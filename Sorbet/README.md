Sorbet (Ruby)
===

Sorbet adds static types to Ruby.

* Language resources:
  - <https://sorbet.org/docs/overview>
  - <https://github.com/sorbet/sorbet>
  - <https://sorbet.org/docs/gradual>
  - <https://sorbet.org/docs/from-typescript>
* If-T version: **1.0**
* Implementation: [./main.rb](./main.rb), [./examples.rb](./examples.rb)
* Raw command to run the benchmark: `srb tc main.rb`, `srb tc examples.rb` (or, using `bundler`: `bundle exec srb tc main.rb`, `bundle exec srb tc examples.rb`)

## Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the dynamic type? If these types do not exist, explain the alternatives.

* Top = `T.anything`
* Bottom = `T.noreturn`
* Dynamic = `T.untyped`

`T.untyped` is Sorbet’s dynamic type, used for values with unknown types, such as those from untyped Ruby code. It allows any operation but provides no type safety. Sorbet supports gradual typing, so `T.untyped` is common in mixed typed/untyped codebases.

<https://sorbet.org/docs/static>

> Q. What base types does this implementation use? Why?

`String`, `Integer`, `TrueClass`, and `FalseClass`

These are standard Ruby classes, chosen for their simplicity and immutability, making them suitable for testing type narrowing in Sorbet. Since Ruby allows subclassing (e.g., a user can define a subclass of `String`), Sorbet uses `is_a?` for type checks, which respects subclass relationships, avoiding issues seen in other languages (e.g., Python’s `type is` with `str` subclasses).

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

`T.let(x, T)` and `T.cast(x, T)` assign type `T` to `x`. Both update the type environment statically.

Example: `T.cast(x, String)` ensures `x` is treated as `String`.

- `T.let` is normally used for local type annotations. It does a static check and a runtime check.
- `T.cast` inserts runtime checks (in strict mode) to enforce the type. It does only a runtime check, no static check.

<https://sorbet.org/docs/type-assertions>

> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

N/A. Sorbet does not support type-narrowing predicates.

> Q. If the language supports other type-narrowing predicates, describe them below.

N/A. Sorbet does not support type-narrowing predicates.

## Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

Predicate-related benchmarks (`predicate_2way`, `predicate_1way`, `predicate_checked`) are not expressible in Sorbet due to the lack of type predicate support. All other benchmarks are fully expressible.

> Q. Are any benchmarks expressed particularly well, or particularly poorly? Explain.

* **Well-expressed**: `positive`, `negative`, `alias`, `connectives`, `nesting_body`, `nesting_condition` use straightforward `is_a?` checks and align closely with Ruby’s dynamic typing idioms, making them natural for Sorbet’s flow-sensitive typing.
* **Poorly-expressed**: `predicate_2way`, `predicate_1way`, `predicate_checked` are stubs due to the lack of type predicate support. Success cases return dummy values, and failure cases trigger artificial type errors (e.g., `x.is_nan`).

> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

The implementation is direct for most benchmarks, using Ruby’s `if`/`else` and `is_a?` to mirror If-T’s pseudocode. Exceptions:
* Predicate benchmarks use stubs instead of predicate logic.
* `tuple_length` uses union types (`T.any([Integer, Integer], [String, String, String])`) to encode size distinctions, which is less direct but necessary for static typing.


## Advanced Examples

> Q. Are any examples inexpressible? Why?

`tree_node` is inexpressible because Sorbet does not have type predicates.

`filter` is inexpressible, again because it requires a predicate, though we have implemented a simple version of `filter`.


> Q. Are any examples expressed particularly well, or particularly poorly? Explain.

- Well-expressed: The `rainfall` example is expressed effectively in Sorbet. It uses `T::Hash[Symbol, T.untyped]` to model JSON-like data and `T.let` for type narrowing, closely mirroring the If-T pseudocode. The failure case (`rainfall_failure`) triggers a clear type error by casting `rainfall` to `String`, demonstrating Sorbet’s ability to catch invalid operations.
- Poorly-expressed:
  + The `flatten` example is less elegant than the If-T pseudocode. Sorbet requires separate checks for `is_a?(Array)` and `length == 0`, unlike TypeScript’s `empty?` predicate, which combines both. Additionally, the use of `T.untyped` as the input type and multiple `T.let` assertions for type narrowing makes the implementation more verbose.
  + The `filter` example takes a boolean function instead of a type predicate. It also struggles with return type `T::Array[T.untyped]`, which is too permissive, requiring a return type adjustment to `T::Array[Integer]` to enforce errors.


> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

The implementations are mostly direct but slightly more complex than the If-T pseudocode due to Sorbet’s static type system. Key differences include:

- Explicit type narrowing with `T.let` and `T.cast` is needed in all examples to satisfy Sorbet’s strict mode, adding verbosity compared to the pseudocode’s implicit type assumptions.
- The `tree_node` example requires recursive type checks with `T::Hash[Symbol, T.untyped]`, which is straightforward but involves more boilerplate than TypeScript’s predicates.
- The `flatten` example’s recursive structure is direct, but the lack of a combined `empty?` predicate and the need for `T.let` assertions increase complexity.
- The `rainfall` example is the most direct, with minimal divergence from the pseudocode, though it still requires explicit null checks and type assertions.

Overall, Sorbet’s lack of type predicates and permissive `T.untyped` necessitate additional type annotations and checks, making the code less concise than the pseudocode or TypeScript equivalents.
