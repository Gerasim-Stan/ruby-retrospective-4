require 'set'

class NumberSet
  include Enumerable

  def initialize
    @set = Set.new
  end

  def [](filter)
    new_set = NumberSet.new
    filtered_sets = []
    filter.filters.each { |filter| filtered_sets << filter.filter(@set.to_a) }
    filtered_sets.each { |set| filtered_sets[0] = set & filtered_sets[0] }
    filtered_sets[0].each { |number| new_set << number }
    new_set
  end

  def <<(number)
    return if @set.any? { |element| element == number }
    @set << number
  end

  def empty?
    @set.empty?
  end

  def size
    @set.size
  end

  def each(&block)
    @set.each(&block)
  end
end

class SignFilter
  include Enumerable

  attr_accessor :subset_type

  attr :filters

  def initialize(subset_type)
    @subset_type = subset_type
    @filters = [self]
  end

  def filter(array)
    case @subset_type
      when :positive     then array.select { |element| element > 0 }
      when :non_positive then array.select { |element| element <= 0 }
      when :negative     then array.select { |element| element < 0 }
      when :non_negative then array.select do |element|
        element.class != Complex and element >= 0
      end
    end
  end

  def &(filter)
    @filters << filter
    self
  end

  def |(filter)
    @filters << filter
    self
  end

  def each(&block)
    @array.each(&block)
  end
end

class Filter
  attr_accessor :block

  attr :filters

  def initialize(&block)
    @block = block
    @filters = [self]
  end

  def filter(array)
    array.select { |element| @block.call(element.to_i) }
  end

  def &(filter)
    @filters << filter
    self
  end

  def |(filter)
    @filters << filter
    self
  end
end

class TypeFilter
  attr_accessor :type_filter

  attr :filters

  def initialize(type_filter)
    @type_filter = type_filter
    @filters = [self]
  end

  def filter(array)
    case type_filter
      when :integer then array.select { |element| element.is_a? Fixnum }
      when :complex then array.select { |element| element.is_a? Complex }
      when :real    then array.select do |element|
        element.class == Float or element.is_a? Rational
      end
    end
  end

  def &(filter)
    @filters << filter
    self
  end

  def |(filter)
    @filters << filter
    self
  end
end

