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
    
## Example struct_fields
## success
class StructFieldsSuccessApple:
    def __init__(self, a):
        self.a = a

def struct_fields_success_f(x: StructFieldsSuccessApple) -> int:
    if type(x.a) is FinalInt:
        return x.a
    else:
        return 0

## failure
class StructFieldsFailureApple:
    def __init__(self, a):
        self.a = a

def struct_fields_failure_f(x: StructFieldsFailureApple) -> int:
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

## Example nesting_condition
## success
def nesting_condition_success_f(x: object, y: object) -> int:
    if (type(y) is str) if (type(x) is int) else False:
        return x + len(y)
    else:
        return 0

## failure
def nesting_condition_failure_f(x: object, y: object) -> int:
    if (type(y) is str) if (type(x) is int) else (type(y) is str):
        return x + len(y)
    else:
        return 0
    
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
def predicate_checked_success_f(x: FinalStr | FinalInt | bool) -> TypeIs[FinalStr]:
    return type(x) is FinalStr

def predicate_checked_success_g(x: FinalStr | FinalInt | bool) -> TypeIs[FinalInt | bool]:
    return not predicate_checked_success_f(x)

## failure
def predicate_checked_failure_f(x: FinalStr | FinalInt | bool) -> TypeIs[FinalStr]:
    return type(x) is FinalStr or type(x) is FinalInt

def predicate_checked_failure_g(x: FinalStr | FinalInt | bool) -> TypeIs[FinalInt | bool]:
    return type(x) is FinalInt


# =============================
# 🧪 Test Runner: main()
# =============================
def main():
    print("🚀 Running all tests...\n")
    
    # Map of test name -> (function, input(s))
    test_cases = [
        # Example positive
        ("positive_success_f", positive_success_f, [FinalStr("hello"), 42]),
        ("positive_failure_f", positive_failure_f, [FinalStr("hello"), 42]),

        # Example negative
        ("negative_success_f", negative_success_f, [FinalStr("a"), FinalInt(5)]),
        ("negative_failure_f", negative_failure_f, [FinalStr("a"), FinalInt(5), True]),

        # Example connectives
        ("connectives_success_f", connectives_success_f, [FinalStr("a"), FinalInt(5)]),
        ("connectives_success_g", connectives_success_g, [FinalStr("a"), FinalInt(5), True]),
        ("connectives_success_h", connectives_success_h, [FinalStr("a"), FinalInt(5), True]),
        ("connectives_failure_f", connectives_failure_f, [FinalStr("a"), FinalInt(5)]),
        ("connectives_failure_g", connectives_failure_g, [FinalStr("a"), FinalInt(5), True]),
        ("connectives_failure_h", connectives_failure_h, [FinalStr("a"), FinalInt(5), True]),

        # Example nesting_body
        ("nesting_body_success_f", nesting_body_success_f, [FinalStr("a"), FinalInt(5), True]),
        ("nesting_body_failure_f", nesting_body_failure_f, [FinalStr("a"), FinalInt(5), True]),

        # Example struct_fields
        ("struct_fields_success_f", struct_fields_success_f, [StructFieldsSuccessApple(FinalInt(5))]),
        ("struct_fields_failure_f", struct_fields_failure_f, [StructFieldsFailureApple(FinalStr("a"))]),

        # Example tuple_elements
        ("tuple_elements_success_f", tuple_elements_success_f, [(FinalInt(5), "b")]),
        ("tuple_elements_failure_f", tuple_elements_failure_f, [(FinalInt(5), "b")]),

        # Example tuple_length
        ("tuple_length_success_f", tuple_length_success_f, [(FinalInt(1), FinalInt(2)), (FinalStr("a"), FinalStr("b"), FinalStr("c"))]),
        ("tuple_length_failure_f", tuple_length_failure_f, [(FinalInt(1), FinalInt(2)), (FinalStr("a"), FinalStr("b"), FinalStr("c"))]),

        # Example alias
        ("alias_success_f", alias_success_f, [FinalStr("a"), 42]),
        ("alias_failure_f", alias_failure_f, [FinalStr("a")]),
        ("alias_failure_g", alias_failure_g, [FinalStr("a")]),

        # Example nesting_condition
        ("nesting_condition_success_f", nesting_condition_success_f, [FinalInt(5), FinalStr("x")]),
        ("nesting_condition_failure_f", nesting_condition_failure_f, [FinalInt(5), FinalStr("x")]),

        # Example merge_with_union
        ("merge_with_union_success_f", merge_with_union_success_f, [FinalStr("a"), FinalInt(5), None]),
        ("merge_with_union_failure_f", merge_with_union_failure_f, [FinalStr("a"), FinalInt(5), None]),

        # Example predicate_2way
        ("predicate_2way_success_g", predicate_2way_success_g, [FinalStr("a"), FinalInt(5)]),
        ("predicate_2way_failure_g", predicate_2way_failure_g, [FinalStr("a"), FinalInt(5)]),

        # Example predicate_1way
        ("predicate_1way_success_g", predicate_1way_success_g, [FinalStr("a"), FinalInt(5)]),
        ("predicate_1way_failure_g", predicate_1way_failure_g, [FinalStr("a"), FinalInt(5)]),

        # Example predicate_checked
        ("predicate_checked_success_g", predicate_checked_success_g, [FinalStr("a"), FinalInt(5), True]),
        ("predicate_checked_failure_g", predicate_checked_failure_g, [FinalStr("a"), FinalInt(5), True]),
    ]

    passed = 0
    failed = 0

    for name, func, inputs in test_cases:
        for i, inp in enumerate(inputs):
            try:
                result = func(inp)
                print(f"✅ {name} (input {i+1}) → returned: {result}")
                passed += 1
            except Exception as e:
                print(f"❌ {name} (input {i+1}) → raised: {e}")
                failed += 1

    print("\n📊 Summary:")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")

if __name__ == "__main__":
    main()