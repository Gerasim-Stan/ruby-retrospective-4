def series_calculation(predecessor, ante_predecessor, index)
  return [predecessor, ante_predecessor].max if index == 1
  3.upto(index) do |step|
    predecessor, ante_predecessor =
      sum_predecessors_over_step_parity(predecessor, ante_predecessor, step)
  end
  index.even? ? predecessor : ante_predecessor
end

def sum_predecessors_over_step_parity(predecessor, ante_predecessor, step)
  case step.even?
    when true  then predecessor      += ante_predecessor
    when false then ante_predecessor += predecessor
  end
  return predecessor, ante_predecessor
end

def series(sequence_name, index)
  case sequence_name
    when 'fibonacci' then series_calculation(1, 1, index)
    when 'lucas'     then series_calculation(1, 2, index)
    when 'summed'
      series_calculation(1, 1, index) + series_calculation(1, 2, index)
  end
end

