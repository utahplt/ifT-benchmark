// @flow

/// Code:
// Example filter
// success
function filter_success<T, S: T>(
  array: T[],
  callbackfn: (value: T) => value is S
): S[] {
  const result: S[] = [];
  for (const value of array) {
    if (callbackfn(value)) {
      result.push(value);
    }
  }
  return result;
}

// failure
function filter_failure<T, S: T>(
  array: T[],
  callbackfn: (value: T) => value is S
): S[] {
  const result: S[] = [];
  for (const value of array) {
    if (callbackfn(value)) {
      result.push(value);
    } else {
      result.push(value);
    }
  }
  return result;
}

// Example flatten
// success
type MaybeNestedListSuccess = (number | MaybeNestedListSuccess)[] | number
function flatten_success(l: MaybeNestedListSuccess): number[] {
  if (Array.isArray(l)) {
    if (l.length === 0) {
      return [];
    } else {
      return flatten_success(l[0]).concat(flatten_success(l.slice(1)))
    }
  } else {
    return [l];
  }
}

// failure
type MaybeNestedListFailure = (number | MaybeNestedListFailure)[] | number
function flatten_failure(l: MaybeNestedListFailure): number[] {
  if (Array.isArray(l)) {
    if (l.length === 0) {
      return [];
    } else {
      return flatten_failure(l[0]).concat(flatten_failure(l.slice(1)))
    }
  } else {
    return l;
  }
}

// Example tree_node
// success
interface TreeNodeSuccess {
  value: number;
  children?: TreeNodeSuccess[];
  // Recursive reference to the same type
}

function isTreeNodeSuccess(node: any): node is TreeNodeSuccess {
  if (typeof node !== 'object' || node === null) {
    return false;
  }

  if (typeof node.value !== 'number') {
    return false;
  }

  if (node.children) {
    if (!Array.isArray(node.children)) {
      return false;
    }

    // Recursively check each child
    for (const child of node.children) {
      if (!isTreeNodeSuccess(child)) {
        return false;
      }
    }
  }
  return true;
}

// failure
interface TreeNodeFailure {
  value: number;
  children?: TreeNodeFailure[];
  // Recursive reference to the same type
}

function isTreeNodeFailure(node: any): node is TreeNodeFailure {
  if (typeof node !== 'object' || node === null) {
    return false;
  }

  if (typeof node.value !== 'number') {
    return false;
  }

  if (node.children) {
    if (!Array.isArray(node.children)) {
      return false;
    }

    return true;
  }
  return true;
}

// Example rainfall
// success
function rainfall_success(weather_reports : mixed[]): number {
  let total = 0, count = 0;
  for (let day of weather_reports) {
    if (typeof day === "object" && day) {
      if ("rainfall" in day) {
        const val = day["rainfall"]
        if (typeof val === "number" && 0 <= val && val <= 999) {
          total += val;
          count += 1;
        }
      }
    }
  }
  if (count > 0) {
    return total / count;
  } else {
    return 0;
  }
}

// failure
function rainfall_failure(weather_reports : mixed[]): number {
  let total = 0, count = 0;
  for (let day of weather_reports) {
    if (typeof day === "object" && day) {
      if ("rainfall" in day) {
        const val = day["rainfall"]
        total += val;
        count += 1;
      }
    }
  }
  if (count > 0) {
    return total / count;
  } else {
    return 0;
  }
}
