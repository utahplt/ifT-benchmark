# typed: strict
extend T::Sig

### Code:
## Example filter
## success
sig { params(array: T::Array[T.untyped], callbackfn: T.proc.params(value: T.untyped).returns(T::Boolean)).returns(T::Array[T.untyped]) }
def filter_success(array, callbackfn)
  result = T.let([], T::Array[T.untyped])
  array.each do |value|
    if callbackfn.call(value)
      result << value
    end
  end
  result
end

## failure
sig { params(array: T::Array[T.untyped], callbackfn: T.proc.params(value: T.untyped).returns(T::Boolean)).returns(T::Array[Integer]) }
def filter_failure(array, callbackfn)
  result = T.let([], T::Array[Integer])
  array.each do |value|
    if callbackfn.call(value)
      result << T.cast(value, Integer)
    else
      result << "string" # Expected error: Cannot append String to T::Array[Integer]
    end
  end
  result
end

## Example flatten
## success
sig { params(l: T.untyped).returns(T::Array[Integer]) }
def flatten_success(l)
  if l.is_a?(Array)
    if l.length == 0
      T.let([], T::Array[Integer])
    else
      first = T.let(flatten_success(l[0]), T::Array[Integer])
      rest = T.let(flatten_success(l[1..-1] || []), T::Array[Integer])
      T.let(first.concat(rest), T::Array[Integer])
    end
  else
    T.let([T.cast(l, Integer)], T::Array[Integer])
  end
end

## failure
sig { params(l: T.untyped).returns(T::Array[Integer]) }
def flatten_failure(l)
  if l.is_a?(Array)
    if l.length == 0
      T.let([], T::Array[Integer])
    else
      first = T.let(flatten_failure(l[0]), T::Array[Integer])
      rest = T.let(flatten_failure(l[1..-1] || []), T::Array[Integer])
      T.let(first.concat(rest), T::Array[Integer])
    end
  else
    T.let(l, Integer) # Expected error: Expected T::Array[Integer] but found Integer
  end
end

## Example tree_node
## success
class TreeNodeSuccess
  extend T::Sig
  sig { returns(Integer) }
  attr_reader :value
  sig { returns(T.nilable(T::Array[TreeNodeSuccess])) }
  attr_reader :children

  sig { params(value: Integer, children: T.nilable(T::Array[TreeNodeSuccess])).void }
  def initialize(value:, children: nil)
    @value = T.let(value, Integer)
    @children = T.let(children, T.nilable(T::Array[TreeNodeSuccess]))
  end

  sig { params(node: T.untyped).returns(T::Boolean) }
  def self.is_tree_node_success(node)
    return false unless node.is_a?(T::Hash[Symbol, T.untyped]) && !node.nil?
    return false unless T.let(node[:value], T.untyped).is_a?(Integer)
    if node[:children]
      return false unless T.let(node[:children], T.untyped).is_a?(T::Array)
      node[:children].all? { |child| is_tree_node_success(child) }
    else
      true
    end
  end
end

## failure
class TreeNodeFailure
  extend T::Sig
  sig { returns(Integer) }
  attr_reader :value
  sig { returns(T.nilable(T::Array[TreeNodeFailure])) }
  attr_reader :children

  sig { params(value: Integer, children: T.nilable(T::Array[TreeNodeFailure])).void }
  def initialize(value:, children: nil)
    @value = T.let(value, Integer)
    @children = T.let(children, T.nilable(T::Array[TreeNodeFailure]))
  end

  sig { params(node: T.untyped).returns(T::Boolean) }
  def self.is_tree_node_failure(node)
    return false unless node.is_a?(T::Hash[Symbol, T.untyped]) && !node.nil?
    return false unless T.let(node[:value], T.untyped).is_a?(Integer)
    if node[:children]
      T.let(node[:value], Integer).is_nan # Expected error: Method is_nan does not exist on Integer
      true
    else
      true
    end
  end
end

## Example rainfall
## success
sig { params(weather_reports: T::Array[T.untyped]).returns(Float) }
def rainfall_success(weather_reports)
  total = T.let(0.0, Float)
  count = T.let(0, Integer)
  weather_reports.each do |day|
    if day.is_a?(T::Hash[Symbol, T.untyped]) && !day.nil?
      if day.key?(:rainfall)
        val = T.let(day[:rainfall], T.untyped)
        if val.is_a?(Float) && 0.0 <= val && val <= 999.0
          total += val
          count += 1
        end
      end
    end
  end
  count > 0 ? total / count : 0.0
end

## failure
sig { params(weather_reports: T::Array[T.untyped]).returns(Float) }
def rainfall_failure(weather_reports)
  total = T.let(0.0, Float)
  count = T.let(0, Integer)
  weather_reports.each do |day|
    if day.is_a?(T::Hash[Symbol, T.untyped]) && !day.nil?
      if day.key?(:rainfall)
        val = T.cast(day[:rainfall], String)
        total += val # Expected error: Expected Integer but found String
        count += 1
      end
    end
  end
  count > 0 ? total / count : 0.0
end
