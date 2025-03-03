mypy
===

mypy is a typechecker for Python PEP 484 types.

* Language resources:
  - <https://www.mypy-lang.org/>
  - <https://github.com/python/mypy>
  - <https://mypy-play.net/?mypy=latest&python=3.12>
  - <https://peps.python.org/pep-0484/>
* If-T version: **1.0**
* Implementation: [./main.py](./main.py)


#### Type System Basics

> Q. What is the top type in this language? What is the bottom type? What is the dynamic type?
> If these types do not exist, explain the alternatives.

* Top = `object`
* Bottom = `Never`
* Dynamic = `Any`

<https://docs.python.org/3/library/typing.html>


> Q. What base types does this implementation use? Why?

`bool`, `FinalInt`, and `FinalStr`

`bool` is a simple, final base type.

The built-in types `int` and `str` are not final, so we introduce final subtypes to use
in type equality tests.


> Q. What container types does this implementation use (for objects, tuples, etc)? Why?

* Object types for objects: search for `class` in the code
* Tuple types for tuples: `tuple[T, ....]`

Tuples can have any number of elements and are immutable.

Objects have mutable members, but mypy allows type narrowing.


#### Type Narrowing

> Q. How do simple type tests work in this language?

`type(x)` returns a type object that describes the type of the value of `x`. We compare
the results to other type objects using `is`.

Examples: `type(x) is FinalStr`

<https://docs.python.org/3/library/functions.html#type>


> Q. Are there other forms of type test? If so, explain.

* `isinstance(x, classinfo)` : returns true if the type of `x` is a subtype of `classinfo`

<https://docs.python.org/3/library/functions.html#isinstance>


> Q. How do type casts work in this language?

* `typing.cast(type, x)`

Casts assert facts to the typechecker, but these facts are not enforced
dynamically. If `x` is cast to `int` it could still evaluate to a string.

Related forms:

* `typing.assert_type(x, type)` : raise a typechecker error if `x` does not match `type`
* `typing.reveal_type(x)` : print type information

<https://docs.python.org/3/library/typing.html>


> Q. What is the syntax for a symmetric (2-way) type-narrowing predicate?

Symmetric predicates use the return type `TypeIs[T]`.

Example: `def f(x: object) -> TypeIs[str]:`


> Q. If the language supports other type-narrowing predicates, describe them below.

Asymmetric predicates use the return type `TypeGuard[T]`.

Example: `def f(x: object) -> TypeGuard[str]:`



#### Benchmark Details

> Q. Are any benchmarks inexpressible? Why?

No, they are all expressible.

Some fail to typecheck, though.


> Q. Are any benchmarks expressed particularly well, or particularly poorly? Explain.

N/A


> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

Very direct, though we introduce classes for the object benchmarks.


#### Advanced Examples

> Q. Are any examples inexpressible? Why?

`tree_node_failure` incorrectly typechecks.

> Q. Are any examples expressed particularly well, or particularly poorly? Explain.

- The `flatten` example has a slightly different implementation than the pseudocode from If-T, since the `empty?` predicate in the pseudocode checks both if the argument is an array and if it is empty, and this must be done in two separate steps in Python.
- The `TreeNode` example does not use `foldl` as the pseudocode from If-T does, since functions equivalent to `foldl` need to be imported from the `functools` module in Python, and this would add unnecessary complexity to the implementation.
- The `filter` and `rainfall` examples aligns very closely with the pseudocode from If-T. `rainfall` initialize `total` to `0.0` instead of `0` to make mypy happy.

> Q. How direct (or complex) is the implementation compared to the pseudocode from If-T?

Very direct.
