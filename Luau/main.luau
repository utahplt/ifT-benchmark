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
        return x == nil
    else
        return x
    end
end

function alias_failure_g(x: unknown): unknown 
    local y = typeof(x) == "string";
    y = true;
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
      return 0;
    end
end

function connectives_success_g(x: string | number): number 
    if (typeof(x) ~= "number" or typeof(x) ~= "boolean") then
      return connectives_success_f(x)
    else
      return 0;
    end
end

function connectives_success_h(x: string | number | boolean): number 
    if (typeof(x) ~= "boolean" and typeof(x) ~= "number") then
      return #x;
    else
      return 0;
    end
end
  
-- failure
function connectives_failure_f(x: string | number): number
    if (typeof(x) ~= "number") then
        return x + 1;
    else
        return 0;
    end
end

function connectives_failure_g(x: unknown): number
    if (typeof(x) == "string" or typeof(x) == "number") then
        return x + 1;
    else
        return 0;
    end
end

function connectives_failure_h(x: string | number | boolean): number
    if (typeof(x) ~= "boolean" and typeof(x) ~= "number") then
        return x + 1;
    else
        return 0;
    end
end

-- Example nesting_body
-- success
function nesting_body_success_f(x: string | number | boolean): number 
    if (not (typeof(x) == "string")) then
      if (not (typeof(x) == "boolean")) then
        return x + 1;
      else
        return 0;
      end
    else
      return 0;
    end
end

-- failure
function nesting_body_failure_f(x: string | number | boolean): number
    if (typeof(x) == "string" or typeof(x) == "number") then
        if (typeof(x) == "number" or typeof(x) == "boolean") then
            return #x;
        else
        return 0;
        end
    else 
        return 0;
    end
end

-- Example nesting condition
-- success
function nesting_condition_success_f(x: unknown, y: unknown): number
    if typeof(x) == "number" and typeof(y) == "string" then
      return x + #y::string;
    else
      return 0;
    end
end

-- failure
function nesting_condition_failure_f(x: unknown, y: unknown): number 
    if typeof(x) == "number" and typeof(y) == "string" then
        return x + #y::string;
    else
        return 0;
    end
end


-- Example predicate_2way
-- success
function predicate_2way_success_f(x: string | number): boolean
  return typeof(x) == "string";
end

function predicate_2way_success_g(x: string | number): number 
  if (predicate_2way_success_f(x)) then
    return #x;
  else 
    return x;
  end
end

-- failure
function predicate_2way_failure_f(x: string | number): boolean
  return typeof(x) == "string";
end

function predicate_2way_failure_g(x: string | number): number
  if (predicate_2way_failure_f(x)) then
    return x + 1
  else
    return x
  end
end

-- Example predicate_1way
-- success
function predicate_1way_success_f(x: string | number): boolean
  return typeof(x) == "number" and x > 0
end

function predicate_1way_success_g(x: string | number): number
    if (predicate_1way_success_f(x)) then
        return x + 1
    else
        return 0
    end
end

-- failure
function predicate_1way_failure_f(x: string | number): boolean
  return typeof(x) == "number" and x > 0
end

function predicate_1way_failure_g(x: string | number): number
  if (predicate_1way_failure_f(x)) then
    return x + 1;
  else
    return #x;
  end
end

-- Example predicate_checked
-- success
function predicate_checked_success_f(x: string | number | boolean): boolean
  return typeof(x) == "string"
end

function predicate_checked_success_g(x: string | number | boolean): boolean 
  return not predicate_checked_success_f(x);
end

-- failure
function predicate_checked_failure_f(x: string | number | boolean): boolean
  return typeof(x) == "string" or typeof(x) == "number";
end

function predicate_checked_failure_g(x: string | number | boolean): boolean
  return typeof(x) == "number";
end

-- Example object_properties
-- success
function object_properties_success_f(x: { a: unknown }): number 
  if (typeof(x.a) == "number") then
    return x.a;
  else
    return 0;
  end
end

-- failure
function object_properties_failure_f(x: { a: unknown }): number
  if (typeof(x.a) == "string") then
    return x.a;
  else
    return 0;
  end
end

-- Example tuple_elements
-- success
type Tuple<T> = {first: T, second: T}

function tuple_elements_success_f(x: Tuple<unknown>): number 
  if (typeof(x[0]) == "number") then
    return x[0];
  else
    return 0;
  end
end

-- failure
function tuple_elements_failure_f(x: Tuple<unknown>): number
  if (typeof(x[0]) == "number") then
    return x[0] + x[1];
  else
    return 0;
  end
end

-- Example tuple_length
-- success
function tuple_length_success_f(x: Tuple<number> | {x: string, y: string, z: string}): number
  if (#x == 2) then
    return x[0] + x[1];
  else
    return #x[0];
  end
end

-- failure
function tuple_length_failure_f(x: Tuple<number> | {x: string, y: string, z: string}): number
  if (#x == 2) then
    return x[0] + x[1];
  else
    return x[0] + x[1];
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
    else if (typeof(x) == "number") then
        x += 1
    else
        return 0
    end
  return x == nil
end
