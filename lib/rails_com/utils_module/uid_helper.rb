# frozen_string_literal: true

module UidHelper
  extend self

  def uuid(int, prefix: '', suffix: '', separator: '')
    str = int.to_s(36)
    str = str + suffix
    str = str.upcase.scan(/.{1,4}/).join(separator)

    if prefix.present?
      str = prefix + '-' + str
    end

    str
  end

  def nsec_uuid(prefix = '', suffix: rand_string, separator: '-')
    time = Time.current
    str = time.to_i.to_s + time.nsec.to_s
    uuid str.to_i, prefix: prefix, suffix: suffix, separator: separator
  end

  def usec_uuid(prefix = '', suffix: rand_string(2), separator: '-')
    time = Time.current
    str = time.to_i.to_s + time.usec.to_s
    uuid str.to_i, prefix: prefix, suffix: suffix, separator: separator
  end

  def sec_uuid(prefix = '', suffix: rand_string(2), separator: '-')
    time = Time.current
    uuid time.to_i, prefix: prefix, suffix: suffix, separator: separator
  end

  def rand_string(len = 4)
    list = (0..9).to_a + ('A'..'Z').to_a
    len.times.map { list.sample }.join
  end

  def decode_uuid(uuid, prefix: true)
    if prefix
      str_arr = uuid.split('-')
      str = str_arr[1..-1].join
    else
      str_arr = uuid.split('-')
      str = str_arr.join
    end

    if str.size >= 12
      str = str[0..11]
      str.to_i(36).to_s
    elsif str.size >= 6 && str.size < 12
      str = str[0..5]
      str.to_i(36).to_s
    else
      raise 'Can not parse the format string!'
    end
  end

end
