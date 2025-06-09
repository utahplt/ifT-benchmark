# typed: strict
extend T::Sig

### Code:
## Example positive
## success
sig { params(x: T.untyped).returns(Integer) }
def positive_success_f(x)
  if x.is_a?(String)
    x.length
  else
    0
  end
end

## failure
sig { params(x: T.untyped).returns(Integer) }
def positive_failure_f(x)
  if x.is_a?(String)
    x.is_nan # Expected error: No method 'is_nan' on String
  else
    0
  end
end

## Example negative
## success
sig { params(x: T.any(String, Integer)).returns(Integer) }
def negative_success_f(x)
  if x.is_a?(String)
    x.length
  else
    x + 1
  end
end

## failure
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def negative_failure_f(x)
  if x.is_a?(String)
    x.length
  else
    x + 1 # Expected error: + not defined for TrueClass | FalseClass
  end
end

## Example alias
## success
sig { params(x: T.untyped).returns(Integer) }
def alias_success_f(x)
  y = x.is_a?(String)
  if y
    x.length
  else
    0
  end
end

## failure
sig { params(x: T.untyped).returns(Integer) }
def alias_failure_f(x)
  y = x.is_a?(String)
  if y
    x.is_nan # Expected error: No method 'is_nan' on String
  else
    0
  end
end

## failure
sig { params(x: T.any(String, Integer)).returns(Integer) }
def alias_failure_g(x)
  y = x.is_a?(String)
  if y
    x.length
  else
    x.length # Expected error: length not defined for Integer
  end
end

## Example connectives
## success
sig { params(x: T.any(String, Integer)).returns(Integer) }
def connectives_success_f(x)
  if !x.is_a?(Integer)
    x.length
  else
    0
  end
end

## success
sig { params(x: T.untyped).returns(Integer) }
def connectives_success_g(x)
  if x.is_a?(String) || x.is_a?(Integer)
    connectives_success_f(x)
  else
    0
  end
end

## success
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def connectives_success_h(x)
  if !x.is_a?(TrueClass) && !x.is_a?(FalseClass) && !x.is_a?(Integer)
    x.length
  else
    0
  end
end

## failure
sig { params(x: T.any(String, Integer)).returns(Integer) }
def connectives_failure_f(x)
  if !x.is_a?(Integer)
    x.is_nan # Expected error: is_nan not defined for String
  else
    0
  end
end

## failure
sig { params(x: T.untyped).returns(Integer) }
def connectives_failure_g(x)
  if x.is_a?(String) || x.is_a?(Integer)
    x.length # Expected error: length not defined for String | Integer
  else
    0
  end
end

## failure
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def connectives_failure_h(x)
  if !x.is_a?(TrueClass) && !x.is_a?(FalseClass) && !x.is_a?(Integer)
    x.is_nan # Expected error: is_nan not defined for String
  else
    0
  end
end

## Example nesting_body
## success
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def nesting_body_success_f(x)
  if !x.is_a?(String)
    if !x.is_a?(TrueClass) && !x.is_a?(FalseClass)
      x + 1
    else
      0
    end
  else
    0
  end
end

## failure
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def nesting_body_failure_f(x)
  if x.is_a?(String) || x.is_a?(Integer)
    if x.is_a?(Integer)
      x.length # Expected error: length not defined for Integer
    else
      0
    end
  else
    0
  end
end

## Example nesting_condition
## success
sig { params(x: T.untyped, y: T.untyped).returns(Integer) }
def nesting_condition_success_f(x, y)
  if x.is_a?(Integer) ? y.is_a?(String) : false
    x + y.length
  else
    0
  end
end

## failure
sig { params(x: T.any(String, Integer), y: T.untyped).returns(Integer) }
def nesting_condition_failure_f(x, y)
  if x.is_a?(Integer) ? y.is_a?(String) : y.is_a?(String)
    x.length # Expected error: length not defined for String | Integer
  else
    0
  end
end

## Example predicate_2way
## success
sig { params(x: T.any(String, Integer)).returns(T::Boolean) }
def predicate_2way_success_f(x)
  raise "Sorbet does not support type predicates"
end

## success
sig { params(x: T.any(String, Integer)).returns(Integer) }
def predicate_2way_success_g(x)
  raise "Sorbet does not support type predicates"
end

## failure
sig { params(x: T.any(String, Integer)).returns(T::Boolean) }
def predicate_2way_failure_f(x)
  raise "Sorbet does not support type predicates"
end

## failure
sig { params(x: T.any(String, Integer)).returns(Integer) }
def predicate_2way_failure_g(x)
  raise "Sorbet does not support type predicates"
end

## Example predicate_1way
## success
sig { params(x: T.any(String, Integer)).returns(T::Boolean) }
def predicate_1way_success_f(x)
  raise "Sorbet does not support type predicates"
end

## success
sig { params(x: T.any(String, Integer)).returns(Integer) }
def predicate_1way_success_g(x)
  raise "Sorbet does not support type predicates"
end

## failure
sig { params(x: T.any(String, Integer)).returns(T::Boolean) }
def predicate_1way_failure_f(x)
  raise "Sorbet does not support type predicates"
end

## failure
sig { params(x: T.any(String, Integer)).returns(Integer) }
def predicate_1way_failure_g(x)
  raise "Sorbet does not support type predicates"
end

## Example predicate_checked
## success
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(T::Boolean) }
def predicate_checked_success_f(x)
  raise "Sorbet does not support type predicates"
end

## success
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(T::Boolean) }
def predicate_checked_success_g(x)
  raise "Sorbet does not support type predicates"
end

## failure
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(T::Boolean) }
def predicate_checked_failure_f(x)
  raise "Sorbet does not support type predicates"
end

## failure
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(T::Boolean) }
def predicate_checked_failure_g(x)
  raise "Sorbet does not support type predicates"
end

## Example object_properties
## success
sig { params(x: { a: T.untyped }).returns(Integer) }
def object_properties_success_f(x)
  if x[:a].is_a?(Integer)
    x[:a]
  else
    0
  end
end

## failure
sig { params(x: { a: T.any(String, Integer) }).returns(Integer) }
def object_properties_failure_f(x)
  if x[:a].is_a?(String)
    T.let(x[:a].length, Integer) # Expected error: Cannot assign String#length to Integer
  else
    x[:a]
  end
end

## Example tuple_elements
## success
sig { params(x: [T.untyped, T.untyped]).returns(Integer) }
def tuple_elements_success_f(x)
  if x[0].is_a?(Integer)
    x[0]
  else
    0
  end
end

## failure
sig { params(x: [Integer, T.any(String, Integer)]).returns(Integer) }
def tuple_elements_failure_f(x)
  if x[0].is_a?(Integer)
    x[1].length # Expected error: length not defined for Integer
  else
    0
  end
end

## Example tuple_length
## success
sig { params(x: T.any([Integer, Integer], [String, String, String])).returns(Integer) }
def tuple_length_success_f(x)
  if x.length == 2
    x[0] + x[1]
  else
    x[0].length
  end
end

## failure
sig { params(x: T.any([Integer, Integer], [String, String, String])).returns(Integer) }
def tuple_length_failure_f(x)
  if x.length == 2
    x[0] + x[1]
  else
    T.let(x[0].length, Integer) # Expected error: Cannot assign String#length to Integer
  end
end

## Example merge_with_union
## success
sig { params(x: T.untyped).returns(T.any(String, Integer)) }
def merge_with_union_success_f(x)
  if x.is_a?(String)
    x += "hello"
  elsif x.is_a?(Integer)
    x += 1
  else
    return 0
  end
  x
end

## failure
sig { params(x: T.untyped).returns(T.any(String, Integer)) }
def merge_with_union_failure_f(x)
  if x.is_a?(String)
    x += "hello"
  elsif x.is_a?(Integer)
    x += 1
  else
    return 0
  end
  x.is_nan # Expected error: No method 'is_nan' on String | Integer
end
