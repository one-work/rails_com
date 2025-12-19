# frozen_string_literal: true
module RailsCom::TimeHelper

  def exact_distance_time(from_time = Time.current, to_time, **options)
    result = TimeHelper.exact_distance_pure_time(from_time, to_time)
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

  def extra_distance_date(from = Date.today, to, **options)
    result = (to.to_date - from.to_date).to_i

    options = {
      scope: 'date.distance_in_words'
    }.merge!(options)

    I18n.with_options locale: options[:locale], scope: options[:scope] do |locale|
      case result
      when 0
        locale.t :zero
      when 1
        locale.t :one
      when 2
        locale.t :two
      else
        locale.t :other, count: result
      end
    end
  end

end
