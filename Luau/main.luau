--!strict

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
        return x+1
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

function negative_failure_f(x: string | number | boolean): number 
    if typeof(x) == "string" then
        return #x
    else 
        return x + 1
    end
end

-- Example alias
-- success
function alias_success_f(x: unknown): unknown
    local y = typeof(x) == "number"
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

-- Example connectives
-- success
function connectives_success_f(x: string | number): number 
    if (typeof(x) ~= "number") then
      return #x
    else
      return 0
    end
end

function connectives_success_g(x: string | number): number 
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
    if (not (typeof(x) == "string")) then
      if (not (typeof(x) == "boolean")) then
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

-- Example nesting condition
-- success
function nesting_condition_success_f(x: unknown, y: unknown): number
    if typeof(x) == "number" and typeof(y) == "string" then
      return x + #y
    else
      return 0
    end
end

-- failure
function nesting_condition_failure_f(x: unknown, y: unknown): number 
  if (typeof(x) == "number" and typeof(y) == "string") or typeof(y) == "string"  then
    return x + #y
  else 
    return 0
  end
end


-- Example predicate_2way
-- success
function predicate_2way_success_f(x: string | number): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

function predicate_2way_success_g(x: string | number): never 
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

-- failure
function predicate_2way_failure_f(x: string | number): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

function predicate_2way_failure_g(x: string | number): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

-- Example predicate_1way
-- success
function predicate_1way_success_f(x: string | number): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

function predicate_1way_success_g(x: string | number): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

-- failure
function predicate_1way_failure_f(x: string | number): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

function predicate_1way_failure_g(x: string | number): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

-- Example predicate_checked
-- success
function predicate_checked_success_f(x: string | number | boolean): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

function predicate_checked_success_g(x: string | number | boolean): never 
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

-- failure
function predicate_checked_failure_f(x: string | number | boolean): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

function predicate_checked_failure_g(x: string | number | boolean): never
-- not representable in Luau (v0.657)
  error("not representable in Luau (v0.657)")
end

-- Example table_properties
-- success

type Apple = {
  a: unknown
}

function table_properties_success_f(x: Apple): number 
  if (typeof(x.a) == "number") then
    return x.a
  else
    return 0
  end
end

-- failure
function table_properties_failure_f(x: Apple): number
  if (typeof(x.a) == "string") then
    return x.a
  else
    return 0
  end
end

-- Example tuple_elements
-- success
type Pair<T> = {first: T, second: T}

function tuple_elements_success_f(x: Pair<unknown>): number 
  if (typeof(x[0]) == "number") then
    return x[0]
  else
    return 0
  end
end

-- failure
function tuple_elements_failure_f(x: Pair<unknown>): number
  if (typeof(x[0]) == "number") then
    return x[0] + x[1]
  else
    return 0
  end
end

-- Example tuple_length
-- success
type Tuple<T> = {first: T, second: T, third: T}

function tuple_length_success_f(x: Pair<number> | Tuple<string>): number
  if (#x == 2) then
    return x[0] + x[1]
  else
    return #x[0]
  end
end

-- failure
function tuple_length_failure_f(x: Pair<number> | Tuple<string>): number
  if (#x == 2) then
    return x[0] + x[1]
  else
    return x[0] + x[1] -- resolves to any? for some reason
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