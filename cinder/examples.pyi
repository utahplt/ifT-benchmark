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


# =============================
# 🧪 Test Runner: main()
# =============================
def main():
    print("🚀 Running all tests...\n")

    passed = 0
    failed = 0

    def run_test(name: str, func: Callable, *inputs):
        nonlocal passed, failed
        try:
            result = func(*inputs)
            print(f"✅ {name} → returned: {result}")
            passed += 1
        except Exception as e:
            print(f"❌ {name} → raised: {e}")
            failed += 1

    # --- filter_success ---
    pred_even = lambda x: x % 2 == 0
    run_test("filter_success", filter_success, [1, 2, 3, 4], pred_even)

    # --- filter_failure ---
    pred_str = lambda x: isinstance(x, str)
    run_test("filter_failure", filter_failure, ["a", 1, "b", 2], pred_str)

    # --- flatten_success ---
    run_test("flatten_success", flatten_success, [1, [2, [3, 4]], 5])

    # --- flatten_failure ---
    run_test("flatten_failure", flatten_failure, [1, [2, [3, 4]], 5])

    # --- is_tree_node_success ---
    tree = (1, [(2, []), (3, [(4, [])])])
    run_test("is_tree_node_success", is_tree_node_success, tree)

    bad_tree = (1, [2, (3, [])])
    run_test("is_tree_node_success", is_tree_node_success, bad_tree)

    # --- is_tree_node_failure ---
    run_test("is_tree_node_failure", is_tree_node_failure, tree)
    run_test("is_tree_node_failure", is_tree_node_failure, bad_tree)

    # --- rainfall_success ---
    weather_data = [
        {"date": "2023-01-01", "rainfall": 10.5},
        {"date": "2023-01-02", "rainfall": 0.0},
        {"date": "2023-01-03", "rainfall": 5.2},
    ]
    run_test("rainfall_success", rainfall_success, weather_data)

    # --- rainfall_failure ---
    run_test("rainfall_failure", rainfall_failure, weather_data)

    print("\n📊 Summary:")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")


if __name__ == "__main__":
    main()