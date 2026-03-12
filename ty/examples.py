from typing import TypeIs, Callable, TypeVar, Union

T = TypeVar("T")
S = TypeVar("S")
type JSON = Union[str, float, bool, None, list[JSON], dict[str, JSON]]

### Code:
## Example filter
## success
def filter_success(l: list[T], predicate: Callable[[T], TypeIs[S]]) -> list[S]:
    result: list[S] = []
    for element in l:
        if predicate(element):
            result.append(element)
    return result

## failure
def filter_failure(l: list[T], predicate: Callable[[T], TypeIs[S]]) -> list[S]:
    result: list[S] = []
    for element in l:
        if predicate(element):
            result.append(element)
        else:
            result.append(element)
    return result

## Example flatten
## success
type MaybeNestedListSuccess = list[MaybeNestedListSuccess] | int
def flatten_success(l: MaybeNestedListSuccess) -> list[int]:
    if isinstance(l, list):
        if l:
            return flatten_success(l[0]) + flatten_success(l[1:])
        else:
            return []
    else:
        return [l]

## failure
type MaybeNestedListFailure = list[MaybeNestedListFailure] | int
def flatten_failure(l: MaybeNestedListFailure) -> list[int]:
    if isinstance(l, list):
        if l:
            return flatten_failure(l[0]) + flatten_failure(l[1:])
        else:
            return []
    else:
        return l

## Example tree_node
## success
type TreeNodeSuccess = tuple[int, list[TreeNodeSuccess]]

def is_tree_node_success(node: object) -> TypeIs[TreeNodeSuccess]:
    if not (isinstance(node, tuple) and len(node) == 2):
        return False
    else:
        if not isinstance(node[0], int):
            return False
        else:
            if not isinstance(node[1], list):
                return False
            else:
                for child in node[1]:
                    if not is_tree_node_success(child):
                        return False
                return True

## failure
type TreeNodeFailure = tuple[int, list[TreeNodeFailure]]

def is_tree_node_failure(node: object) -> TypeIs[TreeNodeFailure]:
    if not (isinstance(node, tuple) and len(node) == 2):
        return False
    else:
        if not isinstance(node[0], int):
            return False
        else:
            if not isinstance(node[1], list):
                return False
            else:
                return True

## Example rainfall
## success
def rainfall_success(weather_reports: list[JSON]) -> float:
    total = 0.0
    count = 0
    for day in weather_reports:
        if isinstance(day, dict) and "rainfall" in day:
            val = day["rainfall"]
            if isinstance(val, float) and 0 <= val <= 999:
                total += val
                count += 1
    return total / count if count > 0 else 0

## failure
def rainfall_failure(weather_reports: list[JSON]) -> float:
    total = 0.0
    count = 0
    for day in weather_reports:
        if isinstance(day, dict) and "rainfall" in day:
            val = day["rainfall"]
            total += val
            count += 1
    return total / count if count > 0 else 0
