from typing import TypeIs, Callable, TypeVar, Union

T = TypeVar("T")
S = TypeVar("S")
def filter(l: list[T], predicate: Callable[[T], TypeIs[S]]) -> list[S]:
    result = []
    for element in l:
        if predicate(element):
            result.append(element)
    return result

type MaybeNestedList[T] = list[MaybeNestedList[T]] | T
def flatten(l: MaybeNestedList[T]) -> list[T]:
    if isinstance(l, list):
        if l:
            return flatten(l[0]) + flatten(l[1:])
        else:
            return []
    else:
        return [l]

type TreeNode = tuple[int, list[TreeNode]]

def is_tree_node(node: object) -> TypeIs[TreeNode]:
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
                    if not is_tree_node(child):
                        return False
                return True

type JSON = Union[str, float, bool, None, list[JSON], dict[str, JSON]]
def rainfall(weather_reports: list[JSON]) -> float:
    total = 0
    count = 0
    for day in weather_reports:
        if isinstance(day, dict) and "rainfall" in day:
            val = day["rainfall"]
            if isinstance(val, float) and 0 <= val <= 999:
                total += val
                count += 1
    return total / count if count > 0 else 0
