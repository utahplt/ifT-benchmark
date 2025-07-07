from typing import Callable, TypeVar, Union, List, Dict, Optional, Tuple

# Use traditional type aliasing instead of 'type JSON = ...'
JSON = Union[str, float, bool, None, List['JSON'], Dict[str, 'JSON']]

T = TypeVar("T")
S = TypeVar("S")

### Code:
### Example filter
## success
def filter_success(l: List[T], predicate: Callable[[T], bool]) -> List[T]:
    result: List[T] = []
    for element in l:
        if predicate(element):
            result.append(element)
    return result

## failure
def filter_failure(l: List[T], predicate: Callable[[T], bool]) -> List[T]:
    result: List[T] = []
    for element in l:
        if predicate(element):
            result.append(element)
        else:
            result.append(element)
    return result


### Example flatten
## success
MaybeNestedListSuccess = Union[List['MaybeNestedListSuccess'], int]
def flatten_success(l: MaybeNestedListSuccess) -> List[int]:
    if isinstance(l, list):
        if l:
            return flatten_success(l[0]) + flatten_success(l[1:])
        else:
            return []
    else:
        return [l]

## failure
MaybeNestedListFailure = Union[List['MaybeNestedListFailure'], int]
def flatten_failure(l: MaybeNestedListFailure) -> List[int]:
    if isinstance(l, list):
        if l:
            return flatten_failure(l[0]) + flatten_failure(l[1:])
        else:
            return []
    else:
        # This is a type mismatch but won't raise at runtime unless strict module supports it
        return l  # Expected List[int], got int


### Example tree_node
## success
TreeNodeSuccess = Tuple[int, List['TreeNodeSuccess']]
def is_tree_node_success(node: object) -> bool:
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
TreeNodeFailure = Tuple[int, List['TreeNodeFailure']]
def is_tree_node_failure(node: object) -> bool:
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


### Example rainfall
## success
def rainfall_success(weather_reports: List[JSON]) -> float:
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
def rainfall_failure(weather_reports: List[JSON]) -> float:
    total = 0.0
    count = 0
    for day in weather_reports:
        if isinstance(day, dict) and "rainfall" in day:
            val = day["rainfall"]
            total += val
            count += 1
    return total / count if count > 0 else 0
