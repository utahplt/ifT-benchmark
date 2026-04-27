--!strict
--!nolint FunctionUnused
-- Linter help: https://luau.org/lint/

type List<T> = {T}
type Pair<A, B> = {first: A, second: B}

--- Code:
-- Example filter
-- success
type Ok<T> = { type: "ok", value: T }
type Err<E> = { type: "err", error: E }
type Result<T, E> = Ok<T> | Err<E>
function filter_success<T, S>(l: List<T>, predicate: (T) -> (Result<S,string>)): List<S>
    local result: List<S> = {}
    for _key, element in l do
        local tmp: Result<S,string> = predicate(element)
        if tmp.type == "ok" then
          table.insert(result, tmp.value)
        end
    end
    return result
end

-- failure
function filter_failure<T, S>(l: List<T>, predicate: (T) -> (Result<S,string>)): List<S>
    local result: List<S> = {}
    for _key, element in l do
        local tmp: Result<S,string> = predicate(element)
        if tmp.type == "ok" then
          table.insert(result, tmp.value)
        else
          table.insert(result, tmp.value)
        end
    end
    return result
end

-- Example flatten
-- success
type MaybeNestedListSuccess = List<MaybeNestedListSuccess> | number
function flatten_success(l: MaybeNestedListSuccess): List<number>
  if type(l) == "table" then
    if #l > 0 then
      local hd = flatten_success(l[0])
      local tl = flatten_success({table.unpack(l, 2, #l)})
      for k, v in tl do
        table.insert(hd, v)
      end
      return hd
    else
      return {}
    end
  else
    return {l}
  end
end

---- failure
type MaybeNestedListFailure = List<MaybeNestedListFailure> | number
function flatten_failure(l: MaybeNestedListSuccess): List<number>
  if type(l) == "table" then
    if #l > 0 then
      local hd = flatten_failure(l[0])
      local tl = flatten_failure({table.unpack(l, 2, #l)})
      for k, v in tl do
        table.insert(hd, v)
      end
      return hd
    else
      return {}
    end
  else
    return l
  end
end

-- Example tree_node
-- success
type TreeNodeSuccess = Pair<number, List<TreeNodeSuccess>>

function is_tree_node_success(node: unknown): never
  error("not representable in Luau (v0.717)")
end

-- failure
function is_tree_node_failure(node: unknown): never
  error("not representable in Luau (v0.717)")
end

-- Example rainfall
-- success
function rainfall_success(weather_reports: List<unknown>): number
  local total: number = 0
  local count: number = 0
  for _key, day in weather_reports do
    if type(day) == "table" then -- this also fails: `day:is("table")`
      if day["rainfall"] then
        local val: unknown = day["rainfall"]
        if type(val) == "number" and 0 <= val and val <= 999 then
          total = total + val
          count = count + val
        end
      end
    end
  end
  if count > 0 then
    return total / count
  else
    return 0
  end
end

-- failure
function rainfall_failure(weather_reports: List<unknown>): number
  local total: number = 0
  local count: number = 0
  for _key, day in weather_reports do
    if type(day) == "table" then -- this also fails: `day:is("table")`
      if day["rainfall"] then
        local val = day["rainfall"]
        total = total + val
        count = count + val
      end
    end
  end
  if count > 0 then
    return total / count
  else
    return 0
  end
end

