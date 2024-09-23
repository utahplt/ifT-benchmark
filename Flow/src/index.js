// @flow

// Example 1
console.log("Example 1")
function example1(x: mixed): number {
    if (typeof x === "number") {
        x = x + 1;
    } else {
        x = 0;
    }
    return x;
}

console.log(example1(1)); // 2
console.log(example1("1")); // 0

// Example 2
console.log("Example 2")
function example2(x: string | number): number {
    if (typeof x === "number") {
        return x + 1;
    } else {
        return x.length;
    }
}

console.log(example2(1)); // 2
console.log(example2("1")); // 1

// Example 3
console.log("Example 3")
function member(l: Array<number>, v: number): Array<number> | false {
    if (l.includes(v)) {
        return l.slice(l.indexOf(v));
    } else {
        return false;
    }
}

function example3(l: Array<number>, v: number): number {
    let x = member(l, v);
    if (x) {
        return x[0];
    } else {
        throw new Error("fail");
    }
}

console.log(example3([1, 2, 3, 4], 1)); // 1

// Example 4
console.log("Example 4")
function example4(x: mixed): number {
    if (typeof x === "number" || typeof x === "string") {
        x = example2(x);
    } else {
        x = 0;
    }
    return x;
}

console.log(example4(1)); // 2
console.log(example4("str")); // 3
console.log(example4(Symbol('sym'))); // 0

// Example 5
console.log("Example 5")
function example5(x: mixed, y: mixed): number {
    if (typeof x === "number" && typeof y === "string") {
        return x + y.length;
    } else {
        return 0;
    }
}

console.log(example5(5, "str")); // 8

// Example 6 (this should fail)
console.log("Example 6")

function example6(x: mixed, y: mixed): number {
    if (typeof x === "number" && typeof y === "string") {
        return x + y.length;
    } else {
        return x.length;
    }
}

console.log(example6(5, "str")); // 8
console.log(example6(5, 5)); // undefined

// Example 7
console.log("Example 7")

// this failed to refine the type of x and y
function example7(x: mixed, y: mixed): number {
    if (typeof x === "number" ? typeof y === "string" : false) {
        return x + y.length;
    } else {
        return 0;
    }
}

// this failed to refine the type of x and y
function example7_2nd_try(x: mixed, y: mixed): number {
    if ((() => {
        if (typeof x === "number") {
            return typeof y === "string";
        } else {
            return false;
        }
    })()) {
        return x + y.length;
    } else {
        return 0;
    }
}

// this failed to refine the type of x and y
function example7_3rd_try(x: mixed, y: mixed): number {
    return (typeof x === "number" ? typeof y === "string" : false) ? x + y.length : 0;
}

// this works
function example7_4th_try(x: mixed, y: mixed): number {
    if (typeof x === "number") {
        if (typeof y === "string") {
            return x + y.length;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

// this works
function example7_5th_try(x: mixed, y: mixed): number {
    return typeof x === "number" ? (typeof y === "string" ? x + y.length : 0) : 0;
}

// conclusion: typescript is not able to refine types in nested conditionals when
// the nesting happens in the condition part of the outer conditional statement, 
// but it is able to refine types in nested conditionals when the nesting happens
// in the body

console.log(example7(5, "str")); // 8
console.log(example7_2nd_try(5, "str")); // 8
console.log(example7_3rd_try(5, "str")); // 8
console.log(example7_4th_try(5, "str")); // 8
console.log(example7_5th_try(5, "str")); // 8

// Example 8
console.log("Example 8")

// user-defined type guards
function example8(x: mixed): x is string | number {
    return typeof x === "number" || typeof x === "string";
    // if you write it like below, it will fail
    // if (typeof x === "number" || typeof x === "string") {
    //     return true;
    // } else {
    //     return false;
    // }
}

let x: mixed = 1;
if (example8(x)) {
    example2(x);
}

// flow allows you to define one-sided type guards
function example8_one_sided(x: number | string): implies x is number {
    return typeof x === "number" && x > 0;
}

let y: number | string = 1;
if (example8_one_sided(y)) {
    example2(y);
} else {
    console.log(y.length); // this does not type check 
}

// Example 9
console.log("Example 9")
// this fails due to the same reason as example 7
function example9(x: mixed): number {
    let tmp = typeof x === "number";
    if (tmp ? tmp : typeof x === "string") {
        return example2(x);
    } else {
        return 0;
    }
}

// this fails because flow cannot track aliasing of test results
function example9_2nd_try(x: mixed): number {
    let tmp = typeof x === "number";
    if (tmp) {
        return example2(x);
    } else if (typeof x === "string") {
        return example2(x);
    } else {
        return 0;
    }
}

// this fails because of the same reason as 2nd try,
// but if use the test_fun(x) directly in the if condition, it works
function example9_3rd_try(x: mixed): number {
    let test_fun = (t): t is number => typeof t === "number";
    let tmp = test_fun(x);
    if (tmp) {
        return example2(x);
    } else if (typeof x === "string") {
        return example2(x);
    } else {
        return 0;
    }
}

function example9_4th_try(x: mixed): number {
    return (typeof x === "number" ? example2(x) : typeof x === "string" ? example2(x) : 0);
}

// Example 10
// check if it refines successfully if using immutable data structures
console.log("Example 10")
function example10(p: [mixed, mixed]): number {
    if (typeof p[0] === "number") {
        return ((_p: [number, mixed]) => _p[0] + 1)(p);
    } else {
        return 0;
    }
}

console.log(example10([1, 2])); // 2

class Pair {
    x: mixed;
    y: mixed;
    constructor(x: mixed, y: mixed) {
        this.x = x;
        this.y = y;
    }
}

function example10_2nd_try(p: Pair): number {
    if (typeof p.x === "number") {
        return p.x + 1; // succeed to refine the type of p.x here at compile time
    } else {
        return 0;
    }
}

// Example 11
console.log("Example 11")

function example11(p: [mixed, mixed]): number {
    if (typeof p[0] === "number" && typeof p[1] === "number") {
        return ((_p: [number, mixed]) => _p[0])(p); // failed to refine the type of p[0] 
    } else {
        return 0;
    }
}

console.log(example11([1, 2])); // 1

function example11_2nd_try(p: Pair): number {
    if (typeof p.x === "number" && typeof p.y === "number") {
        return p.x; // succeeds to refine the type of p.x here at compile time
    } else {
        return 0;
    }
}

function example11_3rd_try(p: [mixed, mixed]): number {
    if (p.every((x) => typeof x === "number")) {
        return p[0];
    } else {
        return 0;
    }
}

// Example 12
console.log("Example 12");

// flow failed to refine the type of x[0] here, a difference to TypeScript!
// give more examples on readonly data structures
function example12(x: [mixed, mixed]): x is [number, mixed] {
    return typeof x[0] === "number";
}

console.log(example12([1, 2])); // true
console.log(example12(["str", 2])); // false

let p: [mixed, mixed] = [1, 2];
if (example12(p)) {
    p;
    console.log(typeof p[0]);
    console.log(p[0] + 1);
}
