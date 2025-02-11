function filter<T, S extends T>(
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

function flatten(l: any): string[] {
  if (Array.isArray(l)) {
    const t = flatten(l[0]).concat(flatten(l.slice(1)));
    return t;
  } else {
    if (typeof l === 'string') {
      return [l];
    } else {
      return [String(l)];
    }
  }
}

interface TreeNode {
    value: number;
    children?: TreeNode[];
    // Recursive reference to the same type
}

function isTreeNode(node: any): node is TreeNode {
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
      if (!isTreeNode(child)) {
        return false;
      }
    }
  }
  return true;
}

function rainfall(weather_reports : object[]): number {
  let total = 0, count = 0;
  for (let day of weather_reports) {
    if ("rainfall" in day) {
      const val = day["rainfall"]
      if (typeof val === "number" && 0 <= val && val <= 999) {
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
