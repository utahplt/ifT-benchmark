# typed: strict
extend T::Sig

# Example positive
sig { params(x: T.untyped).returns(T.untyped) }
def positive_success_f(x)
  if x.is_a?(String)
    x.length
  else
    x
  end
end

sig { params(x: T.untyped).returns(T.untyped) }
def positive_failure_f(x)
  if x.is_a?(String)
    x.is_nan # Expected error: No method 'is_nan' on String
  else
    x
  end
end

# Example negative
sig { params(x: T.any(String, Integer)).returns(Integer) }
def negative_success_f(x)
  if x.is_a?(String)
    x.length
  else
    x + 1
  end
end

sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def negative_failure_f(x)
  if x.is_a?(String)
    x.length
  else
    x + 1 # Expected error: + not defined for TrueClass | FalseClass
  end
end

# Example alias
sig { params(x: T.untyped).returns(T.untyped) }
def alias_success_f(x)
  y = x.is_a?(String)
  if y
    x.length
  else
    x
  end
end

sig { params(x: T.untyped).returns(T.untyped) }
def alias_failure_f(x)
  y = x.is_a?(String)
  if y
    x.is_nan # Expected error: No method 'is_nan' on String
  else
    x
  end
end

sig { params(x: T.untyped).returns(T.untyped) }
def alias_failure_g(x)
  y = x.is_a?(String)
  y = true
  if y
    x.length # Expected error: x not guaranteed to be String
  else
    x
  end
end

# Example connectives
sig { params(x: T.any(String, Integer)).returns(Integer) }
def connectives_success_f(x)
  if !x.is_a?(Integer)
    x.length
  else
    0
  end
end

sig { params(x: T.untyped).returns(Integer) }
def connectives_success_g(x)
  if x.is_a?(String) || x.is_a?(Integer)
    connectives_success_f(x)
  else
    0
  end
end

sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def connectives_success_h(x)
  if x.is_a?(String)
    x.length
  else
    0
  end
end

sig { params(x: T.any(String, Integer)).returns(Integer) }
def connectives_failure_f(x)
  if !x.is_a?(Integer)
    x.is_nan # Expected error: is_nan not defined for String
  else
    0
  end
end

sig { params(x: T.untyped).returns(Integer) }
def connectives_failure_g(x)
  if x.is_a?(String) || x.is_a?(Integer)
    x.length # Expected error: length not defined for String | Integer
  else
    0
  end
end

sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def connectives_failure_h(x)
  if x.is_a?(String)
    x.length
  else
    x.length # Expected error: length not defined for Integer | TrueClass | FalseClass
  end
end

# Example nesting_body
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def nesting_body_success_f(x)
  if x.is_a?(Integer)
    x + 1
  else
    0
  end
end

sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(Integer) }
def nesting_body_failure_f(x)
  if x.is_a?(String) || x.is_a?(Integer)
    x.length # Expected error: length not defined for Integer
  else
    0
  end
end

# Example nesting_condition
sig { params(x: T.untyped, y: T.untyped).returns(Integer) }
def nesting_condition_success_f(x, y)
  if x.is_a?(Integer) ? y.is_a?(String) : false
    x + y.length
  else
    0
  end
end

sig { params(x: T.any(String, Integer), y: T.untyped).returns(Integer) }
def nesting_condition_failure_f(x, y)
  if x.is_a?(Integer) ? y.is_a?(String) : y.is_a?(String)
    x.length # Expected error: length not defined for String | Integer
  else
    0
  end
end

# Example predicate_2way
sig { params(x: T.any(String, Integer)).returns(T::Boolean) }
def predicate_2way_success_f(x)
  x.is_a?(String)
end

sig { params(x: T.any(String, Integer)).returns(Integer) }
def predicate_2way_success_g(x)
  if predicate_2way_success_f(x)
    x.length
  else
    x + 0
  end
end

sig { params(x: T.any(String, Integer)).returns(T::Boolean) }
def predicate_2way_failure_f(x)
  x.is_a?(String)
end

sig { params(x: T.any(String, Integer)).returns(Integer) }
def predicate_2way_failure_g(x)
  if predicate_2way_failure_f(x)
    x.is_nan # Expected error: is_nan not defined for String
  else
    x + 0
  end
end

# Example predicate_1way
sig { params(x: T.any(String, Integer)).returns(T::Boolean) }
def predicate_1way_success_f(x)
  x.is_a?(Integer) && x > 0
end

sig { params(x: T.any(String, Integer)).returns(Integer) }
def predicate_1way_success_g(x)
  if predicate_1way_success_f(x)
    x + 1
  else
    0
  end
end

sig { params(x: T.any(String, Integer)).returns(T::Boolean) }
def predicate_1way_failure_f(x)
  x.is_a?(Integer) && x > 0
end

sig { params(x: T.any(String, Integer)).returns(Integer) }
def predicate_1way_failure_g(x)
  if predicate_1way_failure_f(x)
    x + 1
  else
    x.length # Expected error: length not defined for String | Integer
  end
end

# Example predicate_checked
sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(T::Boolean) }
def predicate_checked_success_f(x)
  x.is_a?(String)
end

sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(T::Boolean) }
def predicate_checked_success_g(x)
  !predicate_checked_success_f(x)
end

sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(T::Boolean) }
def predicate_checked_failure_f(x)
  x.is_a?(String) || x.is_a?(Integer)
end

sig { params(x: T.any(String, Integer, TrueClass, FalseClass)).returns(T::Boolean) }
def predicate_checked_failure_g(x)
  x.is_a?(Integer)
end

# Example object_properties
sig { params(x: { a: T.untyped }).returns(Integer) }
def object_properties_success_f(x)
  if x[:a].is_a?(Integer)
    x[:a]
  else
    0
  end
end

sig { params(x: { a: T.untyped }).returns(Integer) }
def object_properties_failure_f(x)
  if x[:a].is_a?(String)
    x[:a] # Expected error: String not assignable to Integer
  else
    0
  end
end

# Example tuple_elements
sig { params(x: [T.untyped, T.untyped]).returns(Integer) }
def tuple_elements_success_f(x)
  if x[0].is_a?(Integer)
    x[0]
  else
    0
  end
end

sig { params(x: [T.untyped, T.untyped]).returns(Integer) }
def tuple_elements_failure_f(x)
  if x[0].is_a?(Integer)
    x[1].length # Expected error: length not defined for T.untyped
  else
    0
  end
end

# Example tuple_length
sig { params(x: T.any([Integer, Integer], [String, String, String])).returns(Integer) }
def tuple_length_success_f(x)
  if x.length == 2
    x[0] + x[1]
  else
    x[0].length
  end
end

sig { params(x: T.any([Integer, Integer], [String, String, String])).returns(Integer) }
def tuple_length_failure_f(x)
  if x.length == 2
    x[0] + x[1]
  else
    x[0].length # Expected error: length not defined for String
  end
end

# Example merge_with_union
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