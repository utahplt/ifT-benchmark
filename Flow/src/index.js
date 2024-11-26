// @flow

/// Code:
// Example positive
// success
function positive_success_f(x: mixed): mixed {
  if (typeof x === "string") {
    return x.length;
  } else {
    return x
  }
}
// failure
function positive_failure_f(x: mixed): mixed {
  if (typeof x === "string") {
    return x.isNaN();
  } else {
    return x;
  }
}

// Example negative
// success
function negative_success_f(x: string | number): number {
  if (typeof x === "string") {
    return x.length;
  } else {
    return x + 1;
  }
}
// failure
function negative_failure_f(x: string | number | boolean): number {
  if (typeof x === "string") {
    return x.length;
  } else {
    return x + 1;
  }
}

// Example alias
// success
function alias_success_f(x: mixed): mixed {
  const y = typeof x === "string";
  if (y) {
    return x.length;
  } else {
    return x;
  }
}
// failure
function alias_failure_f(x: mixed): mixed {
  const y = typeof x === "string";
  if (y) {
    return x.isNaN();
  } else {
    return x;
  }
}

function alias_failure_g(x: mixed): mixed {
  let y = typeof x === "string";
  y = true;
  if (y) {
    return x.length;
  } else {
    return x;
  }
}

// Example connectives
// success
function connectives_success_f(x: string | number): number {
  if (typeof x !== "number") {
    return x.length;
  } else {
    return 0;
  }
}

function connectives_success_g(x: mixed): number {
  if (typeof x === "string" || typeof x === "number") {
    return connectives_success_f(x);
  } else {
    return 0;
  }
}

function connectives_success_h(x: string | number | boolean): number {
  if (typeof x !== "boolean" && typeof x !== "number") {
    return x.length;
  } else {
    return 0;
  }
}

// failure
function connectives_failure_f(x: string | number): number {
  if (typeof x !== "number") {
    return x + 1;
  } else {
    return 0;
  }
}

function connectives_failure_g(x: mixed): number {
  if (typeof x === "string" || typeof x === "number") {
    return x + 1;
  } else {
    return 0;
  }
}

function connectives_failure_h(x: string | number | boolean): number {
  if (typeof x !== "boolean" && typeof x !== "number") {
    return x + 1;
  } else {
    return 0;
  }
}

// Example nesting_body
// success
function nesting_body_success_f(x: string | number | boolean): number {
  if (!(typeof x === "string")) {
    if (!(typeof x === "boolean")) {
      return x + 1;
    } else {
      return 0;
    }
  } else {
    return 0;
  }
}
// failure
function nesting_body_failure_f(x: string | number | boolean): number {
  if (typeof x === "string" || typeof x === "number") {
    if (typeof x === "number" || typeof x === "boolean") {
      return x.length;
    } else {
      return 0;
    }
  } else {
    return 0;
  }
}

// Example nesting_condition
// success
function nesting_condition_success_f(x: mixed, y: mixed): number {
  if (typeof x === "number" ? typeof y === "string" : false) {
    return x + (y as string).length; // Flow fails to refine type of x here
  } else {
    return 0;
  }
}
// failure
function nesting_condition_failure_f(x: mixed, y: mixed): number {
  if (typeof x === "number" ? typeof y === "string" : typeof y === "string") {
    return x + (y as string).length;
  } else {
    return 0;
  }
}

// Example predicate_2way
// success
function predicate_2way_success_f(x: string | number): x is string {
  return typeof x === "string";
}

function predicate_2way_success_g(x: string | number): number {
  if (predicate_2way_success_f(x)) {
    return x.length;
  } else {
    return x;
  }
}

// failure
function predicate_2way_failure_f(x: string | number): x is string {
  return typeof x === "string";
}

function predicate_2way_failure_g(x: string | number): number {
  if (predicate_2way_failure_f(x)) {
    return x + 1;
  } else {
    return x;
  }
}

// Example predicate_1way
// success
function predicate_1way_success_f(x: string | number): implies x is number {
  return typeof x === "number" && x > 0;
}

function predicate_1way_success_g(x: string | number): number {
  if (predicate_1way_success_f(x)) {
    return x + 1;
  } else {
    return 0;
  }
}

// failure
function predicate_1way_failure_f(x: string | number): implies x is number {
  return typeof x === "number" && x > 0;
}

function predicate_1way_failure_g(x: string | number): number {
  if (predicate_1way_failure_f(x)) {
    return x + 1;
  } else {
    return x.length;
  }
}

// Example predicate_checked
// success
function predicate_checked_success_f(x: string | number): x is string {
  return typeof x === "string";
}

function predicate_checked_success_g(x: string | number): number {
  if (predicate_checked_success_f(x)) {
    return x.length;
  } else {
    return x;
  }
}

// failure
function predicate_checked_failure_f(x: string | number): x is boolean {
  return typeof x === "boolean";
}

function predicate_checked_failure_g(x: string | number): number {
  return true;
}

// Example object_properties
// success
function object_properties_success_f(x: { a: mixed }): number {
  if (typeof x.a === "number") {
    return x.a;
  } else {
    return 0;
  }
}
// failure
function object_properties_failure_f(x: { a: mixed }): number {
  if (typeof x.a === "string") {
    return x.a;
  } else {
    return 0;
  }
}

// Example tuple_elements
// success
function tuple_elements_success_f(x: [mixed, mixed]): number {
  if (typeof x[0] === "number") {
    return x[0];
  } else {
    return 0;
  }
}
// failure
function tuple_elements_failure_f(x: [mixed, mixed]): number {
  if (typeof x[0] === "number") {
    return x[0] + x[1];
  } else {
    return 0;
  }
}

// Example tuple_length
// success
function tuple_length_success_f(x: [number, number] | [string, string, string]): number {
  if (x.length === 2) {
    return x[0] + x[1];
  } else {
    return x[0].length;
  }
}
// failure
function tuple_length_failure_f(x: [number, number] | [string, string, string]): number {
  if (x.length === 2) {
    return x[0] + x[1];
  } else {
    return x[0] + x[1];
  }
}

// Example subtyping_nominal
// success
class A {
  a: number;
}

class B extends A {
  b: number;
}

function subtyping_nominal_success_f(x: A): number {
  if (x instanceof B) {
    return x.b;
  } else {
    return x.a;
  }
}
// failure
function subtyping_nominal_failure_f(x: A): number {
  if (x instanceof B) {
    return x.a;
  } else {
    return x.b;
  }
}

// Example subtyping_structural
// success
function subtyping_structural_success_f(x: mixed): string {
  return "hello";
}

function subtyping_structural_success_g(f: (n: number) => string | boolean): string {
  const r = f(0);
  if (typeof r === "string") {
    return r;
  } else {
    return "world";
  }
}

subtyping_structural_success_g(subtyping_structural_success_f);

// failure
function subtyping_structural_failure_f(x: number): string {
  return "hello";
}

function subtyping_structural_failure_g(f: (x: mixed) => string | boolean): string {
  if (typeof f(0) === "string") {
    return f(0);
  } else {
    return "world";
  }
}

subtyping_structural_failure_g(subtyping_structural_failure_f);

// Example merge_with_union
// success
function merge_with_union_success_f(x: mixed): string | number {
  if (typeof x === "string") {
    x += "hello";
  } else if (typeof x === "number") {
    x += 1;
  } else {
    return 0;
  }
  return x;
}
// failure
function merge_with_union_failure_f(x: mixed): string | number {
  if (typeof x === "string") {
    x += "hello";
  } else if (typeof x === "number") {
    x += 1;
  } else {
    return 0;
  }
  return x.isNaN();
}
