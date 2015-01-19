class NumberSet
  include Enumerable

  def initialize(number_set = [])
    @numbers_set = number_set.uniq
  end

  def [](filter)
    NumberSet.new @numbers_set.select { |number| filter.match? number }
  end

  def <<(number)
    @numbers_set << number unless @numbers_set.include? number
  end

  def empty?
    @numbers_set.empty?
  end

  def size
    @numbers_set.size
  end

  def each(&block)
    @numbers_set.each(&block)
  end
end

class Filter
  def initialize(&block)
    @filter_type = block
  end

  def match?(number)
    @filter_type.call number
  end

  def &(filter)
    Filter.new { |number| match?(number) && filter.match?(number) }
  end

  def |(filter)
    Filter.new { |number| match?(number) || filter.match?(number) }
  end
end

class SignFilter < Filter
  def initialize(subset_type)
    case subset_type
      when :positive     then super() { |number| number >  0 }
      when :non_positive then super() { |number| number <= 0 }
      when :negative     then super() { |number| number <  0 }
      when :non_negative then super() { |number| number >= 0 }
    end
  end
end


class TypeFilter < Filter
  def initialize(filter_type)
    case filter_type
      when :integer then super() { |number| number.is_a? Integer }
      when :complex then super() { |number| number.is_a? Complex }
      when :real
        super() { |number| number.is_a? Float or number.is_a? Rational }
    end
  end
end

