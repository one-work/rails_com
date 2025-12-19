module RegexpUtil
  extend self

  # + one or more times
  # * zero or more times
  # greedy: 贪婪模式，尽可能多次的匹配
  # non greedy：非贪婪模式，尽可能少的
  def between(prefix, suffix, quantifier: '*', greedy: false)
    /(?<=#{prefix}).#{quantifier}#{greedy ? '' : '?'}(?=#{suffix})/
  end

  def least_between(prefix, suffix)
    between(prefix, suffix, quantifier: '+', greedy: false)
  end

  def more_between(prefix, suffix)
    between(prefix, suffix, quantifier: '*', greedy: true)
  end

  def rails_log
    xx(
      method: ['Started ', ' '],
      path: [' "', '" '],
      ip: [' for ', ' '],
      date: [' at ', ' '],
      time: [' ', ' '],
      timezone: [' ', '$']
    )
  end

  def xx(**options)
    r = options.inject([]) do |memo, (key, value)|
      last = memo.pop.to_s
      x = find_common_part(last, value[0])
      memo << [last.delete_suffix(x), x, value[0].delete_prefix(x)].join
      memo << "(?<#{key}>[^#{value[1]}]*)"
      memo << value[1]
    end
    Rails.logger.debug(r)

    /^#{r.join}/
  end

  def find_common_part(str1, str2)
    common_length = [str1.length, str2.length].min

    (0..common_length).reverse_each do |i|
      if str1[-i, i] == str2[0, i]
        return str2[0, i]
      end
    end

    ''
  end

  def china_mobile?(tel)
    tel.to_s.match? /^1(3[0-9]|4[01456879]|5[0-35-9]|6[2567]|7[0-8]|8[0-9]|9[0-35-9])\d{8}$/
  end

end
