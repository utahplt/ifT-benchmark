# Example Programs

The If-T benchmark includes a set of example programs, yet they are more focused on demonstrating the features tested in corresponding benchmark items. The following, however, is a list of example programs that demonstrate practical use cases of those type narrowing features, each may cover multiple benchmark items. They reflect the real-world use cases of type narrowing features in programming languages, and type checkers which support relevant features should be able to type check them correctly.

## `filter`

The `filter` function is a higher-order function that takes a predicate function and a list, and returns a new list that contains only the elements that satisfy the predicate function. When given a type guard function as the predicate function, the type of the elements in the returned list should be narrowed to the type that satisfies the type guard function.

```
define filter(predicate: (x: T) -> x is S, list: Listof(T)) -> Listof(S)
    if empty?(list):
        empty
    else:
        let ([head . tail] = list)
        if predicate(head)
            cons(head, filter(predicate, tail))
        else
            filter(predicate, tail)
```

Another imperative version of the `filter` function is as follows:

```
define filter(predicate: (x: T) -> x is S, list: Listof(T)) -> Listof(S)
    let result = empty
    for each element in list:
        if predicate(element):
            result = cons(element, result)
    return result
```

## `flatten`

The `flatten` function takes anything. If it is not a list, it returns a list containing the input. If it is a list, it returns a new list that contains all the elements in the input list, recursively flattened.

```
define flatten(x: Listof(T | Pairof(T, T))) -> Listof(T):
    if x is empty:
        return [] // is Listof(T)
    else if x[0] is a pair:
        return flatten(x[0]) + flatten(x[1:]) // they are both Listof(T)
    else:
        return [x[0]] + flatten(x[1:]) // x[0] is not a pair
```

## Tree Node

## Rainfall
