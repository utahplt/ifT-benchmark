--!strict
--!nolint FunctionUnused
-- Linter help: https://luau.org/lint/

type Apple = {
  a: unknown
}
type Pair<T> = {first: T, second: T}
type Triple<T> = {first: T, second: T, third: T}

--- Code:
-- Example positive
-- success
function positive_success_f(x: unknown): unknown
  if typeof(x) == "string" then
    return #x
  else
    return x
  end
end

-- failure
function positive_failure_f(x: unknown): unknown
  if typeof(x) == "string" then
    return x + 1
  else
    return x
  end
end

-- Example negative
-- success
function negative_success_f(x: string | number): number
  if typeof(x) == "string" then
    return #x
  else
    return x + 1
  end
end

-- failure
function negative_failure_f(x: string | number | boolean): number
  if typeof(x) == "string" then
    return #x
  else
    return x + 1
  end
end

-- Example connectives
-- success
function connectives_success_f(x: string | number): number
  if (typeof(x) ~= "number") then
    return #x
  else
    return 0
  end
end

function connectives_success_g(x: unknown): number
  if (typeof(x) == "number" or typeof(x) == "string") then
    return connectives_success_f(x)
  else
    return 0
  end
end

function connectives_success_h(x: string | number | boolean): number
  if (typeof(x) ~= "boolean" and typeof(x) ~= "number") then
    return #x
  else
    return 0
  end
end

-- failure
function connectives_failure_f(x: string | number): number
  if (typeof(x) ~= "number") then
    return x + 1
  else
    return 0
  end
end

function connectives_failure_g(x: unknown): number
  if (typeof(x) == "string" or typeof(x) == "number") then
    return x + 1
  else
    return 0
  end
end

function connectives_failure_h(x: string | number | boolean): number
  if (typeof(x) ~= "boolean" and typeof(x) ~= "number") then
    return x + 1
  else
    return 0
  end
end

-- Example nesting_body
-- success
function nesting_body_success_f(x: string | number | boolean): number
  if (typeof(x) ~= "string") then
    if (typeof(x) ~= "boolean") then
      return x + 1
    else
      return 0
    end
  else
    return 0
  end
end

-- failure
function nesting_body_failure_f(x: string | number | boolean): number
  if (typeof(x) == "string" or typeof(x) == "number") then
    if (typeof(x) == "number" or typeof(x) == "boolean") then
      return #x
    else
      return 0
    end
  else
    return 0
  end
end

-- Example struct_fields
-- success
function struct_fields_success_f(x: Apple): number
  if (typeof(x.a) == "number") then
    return x.a
  else
    return 0
  end
end

-- failure
function struct_fields_failure_f(x: Apple): number
  if (typeof(x.a) == "string") then
    return x.a
  else
    return 0
  end
end

-- Example tuple_elements
-- success
function tuple_elements_success_f(x: Pair<unknown>): number
  if (typeof(x.first) == "number") then
    return x.first
  else
    return 0
  end
end

-- failure
function tuple_elements_failure_f(x: Pair<unknown>): number
  if (typeof(x.first) == "number") then
    return x.first + x.second
  else
    return 0
  end
end

-- Example tuple_length
-- success
function tuple_length_success_f(x: Pair<number> | Triple<string>): number
  if (#x == 2) then
    return x.first + x.second
  else
    return #x[0]
  end
end

-- failure
function tuple_length_failure_f(x: Pair<number> | Triple<string>): number
  if (#x == 2) then
    return x.first + x.second
  else
    return x.first + x.second
  end
end

-- Example alias
-- success
function alias_success_f(x: unknown): unknown
  local y = typeof(x) == "string"
  if y then
    return #x
  else
    return x
  end
end

-- failure
function alias_failure_f(x: unknown): unknown
  local y = typeof(x) == "string"
  if y then
    return x + 1
  else
    return x
  end
end

function alias_failure_g(x: unknown): unknown
  local y = typeof(x) == "string"
  y = true
  if (y) then
    return #x
  else
    return x
  end
end

-- Example nesting_condition
-- success
function nesting_condition_success_f(x: unknown, y: unknown): number
  if (if typeof(x) == "number" then typeof(y) == "string" else false) then
    return x + #y
  else
    return 0
  end
end

-- failure
function nesting_condition_failure_f(x: unknown, y: unknown): number
  if (if typeof(x) == "number" then typeof(y) == "string" else typeof(y) == "string")  then
    return x + #y
  else
    return 0
  end
end

-- Example merge_with_union
-- success
function merge_with_union_success_f(x: unknown): string | number
  if (typeof(x) == "string") then
    x = x .. "hello"
  elseif (typeof(x) == "number") then
    x += 1
  else
    return 0
  end
  return x
end

-- failure
function merge_with_union_failure_f(x: unknown): string | number
    if (typeof(x) == "string") then
      x = x .. "hello"
    elseif (typeof(x) == "number") then
      x += 1
    else
      return 0
    end
  return x + 1
end

-- Example predicate_2way
-- success
function predicate_2way_success_helper(x: string | number): never
  error("not representable in Luau (v0.717)")
end

function predicate_2way_success_g(x: string | number): never
  error("not representable in Luau (v0.717)")
end

-- failure
function predicate_2way_failure_helper(x: string | number): never
  error("not representable in Luau (v0.717)")
end

function predicate_2way_failure_g(x: string | number): never
  error("not representable in Luau (v0.717)")
end

-- Example predicate_1way
-- success
function predicate_1way_success_helper(x: string | number): never
  error("not representable in Luau (v0.717)")
end

function predicate_1way_success_g(x: string | number): never
  error("not representable in Luau (v0.717)")
end

-- failure
function predicate_1way_failure_helper(x: string | number): never
  error("not representable in Luau (v0.717)")
end

function predicate_1way_failure_g(x: string | number): never
  error("not representable in Luau (v0.717)")
end

-- Example predicate_checked
-- success
function predicate_checked_success_helper(x: string | number | boolean): never
  error("not representable in Luau (v0.717)")
end

function predicate_checked_success_g(x: string | number | boolean): never
  error("not representable in Luau (v0.717)")
end

-- failure
function predicate_checked_failure_f(x: string | number | boolean): never
  error("not representable in Luau (v0.717)")
end

function predicate_checked_failure_g(x: string | number | boolean): never
  error("not representable in Luau (v0.717)")
end

