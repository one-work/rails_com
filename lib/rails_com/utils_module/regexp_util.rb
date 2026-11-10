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

end
