# frozen_string_literal: true
module RailsCom::TimeHelper

  def distance_time(from_time = Time.current, to_time, **options)
    result = TimeUtil.exact_distance_pure_time(from_time, to_time)
    options = {
      scope: 'datetime.prompts'
    }.merge!(options)
    str = ''

    I18n.with_options locale: options[:locale], scope: options[:scope] do |locale|
      result.each do |k, v|
        str += [v.to_s, locale.t(k)].join
      end
    end

    str
  end

  def distance_date(from = Date.today, to, **options)
    TimeUtil.distance_date(from, to, **options)
  end

end
