def series_calculation(first_term, second_term, index)
  return [first_term, second_term].max if index == 1
  3.upto(index) do |series_step|
    first_term, second_term =
      sum_terms_over_series_step_parity(first_term, second_term, series_step)
  end
  index.even? ? first_term : second_term
end

def sum_terms_over_series_step_parity(first_term, second_term, series_step)
  case series_step.even?
    when true  then first_term  += second_term
    when false then second_term += first_term
  end
  return first_term, second_term
end

def series(sequence_name, index)
  case sequence_name
    when 'fibonacci' then series_calculation(1, 1, index)
    when 'lucas'     then series_calculation(1, 2, index)
    when 'summed'
      series_calculation(1, 1, index) + series_calculation(1, 2, index)
  end
end

