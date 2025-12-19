# frozen_string_literal: true
require 'csv'
class Array

  #   arr = [1, 2, 3]
  #   arr.ljust! 5, nil
  #   # => [nil, nil, 1, 2, 3]
  def ljust!(n, x)
    return self if n < length
    insert(0, *Array.new([0, n - length].max, x))
  end

  # fill an array with the given elements left;
  #   arr = [1, 2, 3]
  #   arr.rjust! 5, nil
  #   # => [1, 2, 3, nil, nil]
  def rjust!(n, x)
    return self if n < length
    fill(x, length...n)
  end

  ##
  #   arr = [1, 2, 3]
  #   arr.mjust!(5, nil)
  #   # => [1, 2, nil, nil, 3]
  def mjust!(n, x)
    return self if n < length
    insert((length / 2.0).ceil, *Array.new(n - length, x))
  end

  ##
  # combine the same key hash like array
  #   raw_data = [
  #     { a: 1 },
  #     { a: 2 },
  #     { b: 2 },
  #     { b: 2 }
  #   ]
  #   raw_data.to_combine_h
  #   #=> { a: [1, 2], b: 2 }
  def to_combine_h
    self.inject({}) do |memo, obj|
      memo.merge(obj) do |_, old_val, new_val|
        v = (Array(old_val) + Array(new_val)).uniq
        v.size > 1 ? v : v[0]
      end
    end
  end

  #
  # raw_data = [
  #   [:a, 1],
  #   [:a, 2, 3],
  #   [:b, 2]
  # ]
  # raw_data.to_array_h
  # #=> [ { a: 1 }, { a: 2 }, { b: 2 } ]
  def to_array_h
    self.map { |x, y| { x => y } }
  end

  # 2D array to csv file
  #   data = [
  #     [1, 2],
  #     [3, 4]
  #   ]
  #   data.to_csv_file
  def to_2d_csv_file(file = 'export.csv')
    CSV.open(file, 'w') do |csv|
      self.each { |ar| csv << ar }
    end
  end

  def to_1d_csv_file(path = 'export.csv')
    File.write(path, join("\n"))
  end

  # 比较两个数组忽略排序的情况下是否相等
  # todo 这个方法不严谨
  def compare(other)
    (self - other).empty? && (other - self).empty?
  end

  # 找出重复的元素
  def find_repeated
    group_by { |item| item }.select { |_, group| group.size > 1 }
  end

  # 合并相邻的相同元素
  def adjoin_repeated(index: 0, excepts: [nil])
    chunk_while { |i, j| i == j }.each_with_object({}) do |arr, h|
      if arr.size > 1
        if excepts.include?(arr[0])
          arr.each_with_index do |arr_item, arr_index|
            h.merge! index + arr_index => arr_item
          end
        else
          h.merge! [index, index + arr.size - 1] => arr[0]
        end
        index += arr.size
      else
        h.merge! index => arr[0]
        index += 1
      end
    end
  end

  # 查找 index, by id
  def find_until(base = 0, limit)
    each_with_index do |i, index|
      base += i[1]
      break self[0..index] if base >= limit
    end
  end

  # [1, 2, 3]
  # => ['1', '1/2', '1/2/3']
  def ancestors(sep = '/')
    map.with_index do |i, index|
      self[0..-size + index].join(sep)
    end
  end

  # [1, 2, 3]
  # => ['1', '2/1', '3/2/1']
  def reverse_ancestors(sep = '/')
    return [] if empty?
    r = [self[0].to_s]

    self[1..].each do |i|
      r << [i, r[-1]].join(sep)
    end

    r
  end

end
