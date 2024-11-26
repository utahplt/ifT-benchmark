from typing import Any, Literal, Set, Type, TypeGuard, TypeVar, Callable, final
from typing_extensions import TypeIs, reveal_type

@final
class FinalStr(str):
    pass

@final
class FinalInt(int):
    pass

### Code:
## Example positive
## success
def positive_success_f(x: object) -> object:
    if type(x) is FinalStr:
        return len(x)
    else:
        return x

## failure
def positive_failure_f(x: object) -> object:
    if type(x) is FinalStr:
        return x + 1
    else:
        return x

## Example negative
## success
def negative_success_f(x: FinalStr | FinalInt) -> int:
    if type(x) is FinalStr:
        return len(x)
    else:
        return x + 1

## failure
def negative_failure_f(x: FinalStr | FinalInt | bool) -> int:
    if type(x) is FinalStr:
        return len(x)
    else:
        return len(x)

## Example alias
## success
def alias_success_f(x: object) -> object:
    y = type(x) is FinalStr
    if y:
        return len(x)
    else:
        return x

## failure
def alias_failure_f(x: object) -> object:
    y = type(x) is FinalStr
    if y:
        return x + 1
    else:
        return x

def alias_failure_g(x: object) -> object:
    y = type(x) is FinalStr
    y = True
    if y:
        return len(x)
    else:
        return x

## Example connectives
## success
def connectives_success_f(x: FinalStr | FinalInt) -> int:
    if type(x) is not FinalInt:
        return len(x)
    else:
        return 0

def connectives_success_g(x: object) -> int:
    if type(x) is FinalStr or type(x) is FinalInt:
        return connectives_success_f(x)
    else:
        return 0

def connectives_success_h(x: FinalStr | FinalInt | bool) -> int:
    if type(x) is not bool and type(x) is not FinalInt:
        return len(x)
    else:
        return 0

## failure
def connectives_failure_f(x: FinalStr | FinalInt) -> int:
    if type(x) is not FinalInt:
        return x + 1
    else:
        return 0

def connectives_failure_g(x: object) -> int:
    if type(x) is FinalStr or type(x) is FinalInt:
        return x + 1
    else:
        return 0

def connectives_failure_h(x: FinalStr | FinalInt | bool) -> int:
    if type(x) is not bool and type(x) is not FinalInt:
        return x + 1
    else:
        return 0

## Example nesting_body
## success
def nesting_body_success_f(x: FinalStr | FinalInt | bool) -> int:
    if not (type(x) is FinalStr):
        if not (type(x) is bool):
            return x + 1
        else:
            return 0
    else:
        return 0

## failure
def nesting_body_failure_f(x: FinalStr | FinalInt | bool) -> int:
    if type(x) is FinalStr or type(x) is FinalInt:
        if type(x) is FinalInt or type(x) is bool:
            return len(x)
        else:
            return 0
    else:
        return 0

## Example nesting_condition
## success
def nesting_condition_success_f(x: object, y: object) -> int:
    if (type(x) is FinalInt and type(y) is FinalStr):
        return x + len(y)
    else:
        return 0

## failure
def nesting_condition_failure_f(x: object, y: object) -> int:
    if (type(x) is FinalInt and type(y) is FinalStr) or type(y) is FinalStr:
        return x + len(y)
    else:
        return 0


## Example predicate_2way
## success
def predicate_2way_success_f(x: FinalStr | FinalInt) -> TypeIs[FinalStr]:
    return type(x) is FinalStr

def predicate_2way_success_g(x: FinalStr | FinalInt) -> int:
    if predicate_2way_success_f(x):
        return len(x)
    else:
        return x

## failure
def predicate_2way_failure_f(x: FinalStr | FinalInt) -> TypeIs[FinalStr]:
    return type(x) is FinalStr

def predicate_2way_failure_g(x: FinalStr | FinalInt) -> int:
    if predicate_2way_failure_f(x):
        return x + 1
    else:
        return x


## Example predicate_1way
## success
def predicate_1way_success_f(x: FinalStr | FinalInt) -> TypeGuard[int]:
    return type(x) is FinalInt and x > 0

def predicate_1way_success_g(x: FinalStr | FinalInt) -> int:
    if predicate_1way_success_f(x):
        return x + 1
    else:
        return 0

## failure
def predicate_1way_failure_f(x: FinalStr | FinalInt) -> TypeGuard[int]:
    return type(x) is FinalInt and x > 0

def predicate_1way_failure_g(x: FinalStr | FinalInt) -> int:
    if predicate_1way_failure_f(x):
        return x + 1
    else:
        return len(x)

## Example predicate_checked
## success
def predicate_checked_success_f(x: FinalStr | FinalInt) -> TypeIs[FinalStr]:
    return type(x) is FinalStr

def predicate_checked_success_g(x: FinalStr | FinalInt) -> int:
    if predicate_checked_success_f(x):
        return len(x)
    else:
        return x

## failure
def predicate_checked_failure_f(x: FinalStr | FinalInt) -> TypeIs[bool]:
    return type(x) is bool

def predicate_checked_failure_g(x: FinalStr | FinalInt) -> int:
    return True

## Example object_properties
## success
class ObjectPropertiesSuccessApple:
    def __init__(self, a):
        self.a = a

def object_properties_success_f(x: ObjectPropertiesSuccessApple) -> int:
    if type(x.a) is FinalInt:
        return x.a
    else:
        return 0

## failure
class ObjectPropertiesFailureApple:
    def __init__(self, a):
        self.a = a

def object_properties_failure_f(x: ObjectPropertiesFailureApple) -> int:
    if type(x.a) is FinalStr:
        return x.a
    else:
        return 0

## Example tuple_elements
## success
def tuple_elements_success_f(x: tuple[object, object]) -> int:
    if type(x[0]) is FinalInt:
        return x[0]
    else:
        return 0

## failure
def tuple_elements_failure_f(x: tuple[object, object]) -> int:
    if type(x[0]) is FinalInt:
        return x[0] + x[1]
    else:
        return 0

## Example tuple_length
## success
def tuple_length_success_f(x: tuple[FinalInt, FinalInt] | tuple[FinalStr, FinalStr, FinalStr]) -> int:
    if len(x) == 2:
        return x[0] + x[1]
    else:
        return len(x[0])

## failure
def tuple_length_failure_f(x: tuple[FinalInt, FinalInt] | tuple[FinalStr, FinalStr, FinalStr]) -> int:
    if len(x) == 2:
        return x[0] + x[1]
    else:
        return x[0] + x[1]

## Example subtyping_nominal
## success
class SubtypingNominalSuccessA:
    def __init__(self, a: FinalInt):
        self.a = a

class SubtypingNominalSuccessB(SubtypingNominalSuccessA):
    def __init__(self, a: FinalInt, b: FinalInt):
        super().__init__(a)
        self.b = b

def subtyping_nominal_success_f(x: SubtypingNominalSuccessA) -> int:
    if type(x) is SubtypingNominalSuccessB:
        return x.b
    else:
        return x.a

## failure
class SubtypingNominalFailureA:
    def __init__(self, a: FinalInt):
        self.a = a

class SubtypingNominalFailureB(SubtypingNominalFailureA):
    def __init__(self, a: FinalInt, b: FinalInt):
        super().__init__(a)
        self.b = b

def subtyping_nominal_failure_f(x: SubtypingNominalFailureA) -> int:
    if type(x) is SubtypingNominalFailureB:
        return x.a
    else:
        return x.b

## Example subtyping_structural
## success
def subtyping_structural_success_f(x: object) -> FinalStr:
    return FinalStr()

def subtyping_structural_success_g(f: Callable[[int], FinalStr | bool]) -> str:
    c = f(0)
    if type(c) is FinalStr:
        return c
    else:
        return "world"

subtyping_structural_success_g(subtyping_structural_success_f)

## failure
def subtyping_structural_failure_f(x: FinalInt) -> FinalStr:
    return FinalStr()

def subtyping_structural_failure_g(f: Callable[[object], FinalStr | bool]) -> str:
    c = f(0)
    if type(c) is FinalStr:
        return c
    else:
        return "world"

subtyping_structural_failure_g(subtyping_structural_failure_f)

## Example merge_with_union
## success
def merge_with_union_success_f(x: object) -> str | int:
    if type(x) is FinalStr:
        x = x + "hello"
    elif type(x) is FinalInt:
        x = x + 1
    else:
        return 0
    return x

## failure
def merge_with_union_failure_f(x: object) -> str | int:
    if type(x) is FinalStr:
        x = x + "hello"
    elif type(x) is FinalInt:
        x = x + 1
    else:
        return 0
    return x + 1
