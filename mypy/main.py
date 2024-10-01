from typing import Any, Literal, Set, TypeGuard, TypeVar
from typing_extensions import TypeIs, reveal_type

### Code:
## Example 1
print("Example 1")
def example1(x: object) -> int:
    if type(x) is int:
        return x + 1
    else:
        return 0

print(example1(1)) # 2
print(example1("1")) # 0

## Example 2
print("\nExample 2")
def example2(x: str | int) -> int:
    if isinstance(x, int):
        return x + 1
    else:
        return len(x)

print(example2(1)) # 2

## Example 3
print("\nExample 3")
def member(l: list[int], v: int) -> list[int] | Literal[False]:
    if v in l:
        return l[l.index(v):]
    else:
        return False

def example3(l: list[int], v: int) -> int:
    if (x := member(l, v)):
        return x[0]
    else:
        raise Exception("fail")

print(example3([1, 2, 3, 4], 1)) # 1

## Example 4
print("\nExample 4")
def example4(x: object) -> int:
    if type(x) == int or type(x) is str:
        return example2(x)
    else:
        return 0

print(example4(1)) # 2
print(example4("str")) # 3
print(example4(1.0)) # 0

## Example 5
print("\nExample 5")
def example5(x: object, y: object) -> int:
    if type(x) == int and type(y) is str:
        return x + len(y)
    else:
        return 0

print(example5(5, "str")) # 8

## Example 6 (this should fail)
print("\nExample 6")
def example6(x: object, y: object) -> int:
    if type(x) == int and type(y) is str:
        return x + len(y)
    else:
        return len(x)

print(example6(5, "str")) # 5
try:
    print(example6(5, 5))
except Exception as e:
    print(e)

## Example 7
print("\nExample 7")
# this failed to refine the type of x and y
def example7(x: object, y: object) -> int:
    if (type(y) == str if type(x) is int else False):
        reveal_type(x)
        return x + len(y)
    else:
        return 0

# this failed to refine the type of x and y
def example7_2nd_try(x: object, y: object) -> int:
    return x + len(y) if (type(y) == str if type(x) == int else False) else 0

# this works
def example7_3rd_try(x: object, y: object) -> int:
    if type(x) is int:
        if type(y) is str:
            return x + len(y)
    return 0

# this works
def example7_4th_try(x: object, y: object) -> int:
    return (x + len(y) if type(y) is str else 0) if type(x) is int else 0

## Example 8
print("\nExample 8")

# user-defined type guard
def example8(x: object) -> TypeIs[str | int]:
    return type(x) is int or type(x) is str

def example8(x: int) -> TypeGuard[str]:
    return True

# note: TypeIs is two-sided, and the original type and
# the refined type must be compatible

x: object = 1
if (example8(x)):
    reveal_type(x)
    example2(x)

# on the other hand, TypeGuard is one-sided, like
# Flow's one-sided type guards, and is not strictly checked

# what is interesting here is that Python supports
# extra arguments in type guards, but only refines
# the type of the first argument
# below is an example taken from the specs
# https://typing.readthedocs.io/en/latest/spec/narrowing.html
def is_str_list(val: list[object], allow_empty: bool) -> TypeGuard[list[str]]:
    if len(val) == 0:
        return allow_empty
    return all(isinstance(x, str) for x in val)

_T = TypeVar("_T")

def is_set_of(val: set[Any], type: type[_T]) -> TypeGuard[Set[_T]]:
    return all(isinstance(x, type) for x in val)

# also, the type guard is not strictly checked
def f(value: int) -> TypeGuard[str]:
    return True

## Example 9
print("\nExample 9")

# this fails due to the same reason as example 7
def example9(x: object) -> int:
    tmp = type(x) is int
    if (tmp if tmp else type(x) is str):
        reveal_type(x) # x: object
        return example2(x)
    else:
        return 0

# this fails because mypy does not track aliasing of test results
# however, Microsoft's proprietary Pylance does
# check Pyright's implementation of aliasing
def example9_2nd_try(x: object) -> int:
    tmp = type(x) is int
    if tmp:
        reveal_type(x)
        return example2(x)
    elif type(x) is str:
        return example2(x)
    else:
        return 0

# same as example9_2nd_try
def example9_3rd_try(x: object) -> int:
    def test(x: object) -> TypeGuard[int]:
        return type(x) is int
    tmp = test(x)
    if tmp:
        reveal_type(x)
        return example2(x)
    elif type(x) is str:
        return example2(x)
    else:
        return 0

def example9_4th_try(x: object) -> int:
    return example2(x) if type(x) is int else example2(x) if type(x) is str else 0

## Example 10
print("\nExample 10")

def example10(p: tuple[object, object]) -> int:
    if type(p[0]) is int:
        reveal_type(p[0])
        # doing better than typed JavaScript's like TypeScript and Flow in such a way that
        # although not able to refine the type of the whole tuple,
        # it can refine the type of single elements
        return p[0]
    else:
        return 0

class Pair:
    def __init__(self, x: object, y: object):
        self.x = x
        self.y = y

def example10_2nd_ver(p: Pair) -> int:
    if type(p.x) is int:
        reveal_type(p.x)
        return p.x
    else:
        return 0

## Example 11
print("\nExample 11")

def example11(p: tuple[object, object]) -> int:
    if type(p[0]) is int and type(p[1]) is int:
        reveal_type(p[0])
        reveal_type(p[1])
        return p[0]
        # doing better than typed JavaScript's like TypeScript and Flow in such a way that
        # although not able to refine the type of the whole tuple,
        # it can refine the type of single elements
    else:
        return 0

def example11_2nd_ver(p: Pair) -> int:
    if type(p.x) is int and type(p.y) is int:
        reveal_type(p.x)
        reveal_type(p.y)
        return p.x
    else:
        return 0

# this fails (maybe some other function will work?)
def example11_3rd_ver(p: Pair) -> int:
    if all(isinstance(x, int) for x in [p.x, p.y]):
        reveal_type(p.x)
        reveal_type(p.y)
        return p.x

## Example 12
print("\nExample 12")

def example12(p: tuple[object, object]) -> TypeIs[tuple[int, object]]:
    return type(p[0]) is int

print(example12((1, 2))) # True
print(example12(("1", 2))) # False

p: tuple[object, object] = (1, 2)
if (example12(p)):
    reveal_type(p)
    reveal_type(p[0])
    reveal_type(p[1])

## Example 13
print("\nExample 13")

def example13(x: object, y: object) -> int:
    if type(x) is int and type(y) is str:
        reveal_type(x)
        reveal_type(y)
        return x + len(y)
    elif type(x) is int:
        reveal_type(x)
        reveal_type(y)
        return x
    else:
        reveal_type(x)
        reveal_type(y)
        return 0

## Example 14
print("\nExample 14")

def example14(input: int | str, extra: tuple[object, object]) -> int:
    if type(input) is int and type(extra[0]) is int:
        reveal_type(input)
        reveal_type(extra[0])
        return input + extra[0]
    elif type(extra[0]) is int:
        reveal_type(input)
        reveal_type(extra[0])
        return extra[0]
    else:
        reveal_type(input)
        reveal_type(extra[0])
        return 0

### End
