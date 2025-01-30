# Example Programs

The If-T benchmark includes a set of example programs, yet they are more focused on demonstrating the features tested in corresponding benchmark items. The following, however, is a list of example programs that demonstrate practical use cases of those type narrowing features, each may cover multiple benchmark items. They reflect the real-world use cases of type narrowing features in programming languages, and type checkers which support relevant features should be able to type check them correctly.

## `filter`

The `filter` function is a higher-order function that takes a predicate function and a list, and returns a new list that contains only the elements that satisfy the predicate function. When given a type guard function as the predicate function, the type of the elements in the returned list should be narrowed to the type that satisfies the type guard function.

```
define filter(predicate: (x: T) -> x is S, list: Listof(T)) -> Listof(S)
    if empty?(list):
        return []
    else:
        let [head . tail] = list
        if predicate(head)
            return cons(head, filter(predicate, tail))
        else
            return filter(predicate, tail)
```

Another imperative version of the `filter` function is as follows:

```
define filter(predicate: (x: T) -> x is S, list: Listof(T)) -> Listof(S)
    let result = []
    for each element in list:
        if predicate(element):
            result = cons(element, result)
    return result
```

## `flatten`

The `flatten` function takes anything. If it is not a list, it returns a list containing the input. If it is a list, it returns a new list that contains all the elements in the input list, recursively flattened.

```
define flatten(x: Any -> Listof(Any \ Listof(Any, Any))):
    if empty?(x):
        return []
    else if x is Listof(Any):
        let [head . tail] = x
        return append(flatten(head), flatten(tail))
    else:
        return [x]
```

## Tree Node

This is an example of recursive predicates. The `TreeNode` is defined to be a recursive type, where each node is a pair of a number and a list of `TreeNode`s. The `IsTreeNode?` function checks if the input is a `TreeNode` or not.

```
type TreeNode = Pairof(Number, Listof(TreeNode))

define IsTreeNode?(node: Top) -> node is TreeNode
    if node is not Pairof(Any, Any):
        return false
    else:
        let ([head . tail] = node)
        if head is not Number:
            return false
        else:
            if tail is not Listof(Any):
                return false
            else:
                return foldl(and, true, map(IsTreeNode?, tail))
```

## Rainfall
