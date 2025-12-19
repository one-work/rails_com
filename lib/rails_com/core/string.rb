require 'reline'
class String

  def integer?
    Integer(self).is_a?(Integer)
  rescue ArgumentError, TypeError
    false
  end

  def numeric?
    Float(self).is_a?(Numeric)
  rescue ArgumentError, TypeError
    false
  end

  def to_controller
    r = camelize
    if r.end_with?('Controller')
      r.safe_constantize
    else
      "#{r}Controller".safe_constantize
    end
  end

  def start_with_same(another)
    _chars = another.chars_step
    _chars.each_with_index do |i, index|
      break index >= 1 ? _chars[index - 1] : '' unless start_with?(i)
    end
  end

  # '123'
  # => '1', '12', '123'
  def chars_step
    chars.ancestors('')
  end

  def display_width
    ::Reline::Unicode.calculate_width(self)
  end

  def split_by_display_width(max_width)
    arr, _ = ::Reline::Unicode.split_by_width(self, max_width)
    arr.compact_blank!
  end

end
