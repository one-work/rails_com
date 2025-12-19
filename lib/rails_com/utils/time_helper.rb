# frozen_string_literal: true

module TimeHelper
  extend self

  def exact_distance_time(from_time = Time.current, to_time)
    min_time, max_time = [from_time.to_datetime, to_time.to_datetime].sort!
    years = max_time.year - min_time.year
    months = max_time.month - min_time.month
    days = max_time.mday - min_time.mday
    day_seconds = max_time.seconds_since_midnight.to_i - min_time.seconds_since_midnight.to_i

    if day_seconds < 0
      days -= 1
      day_seconds = 86400 + day_seconds
    end

    if days < 0
      months -= 1
      days = max_time.prev_month.end_of_month.mday + days
    end

    if months < 0
      years -= 1
      months = 12 + months
    end

    hours, minute_seconds = day_seconds.to_i.divmod(3600)
    minutes, seconds = minute_seconds.divmod(60)

    { year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds }
  end

  def exact_distance_pure_time(from_time = Time.current, to_time)
    result = exact_distance_time(from_time, to_time)
    drop_zero = result.drop_while(&->(i){ i[1] <= 0 }).to_h
    drop_zero[:minute] = drop_zero[:minute].to_s.rjust(2, '0') if drop_zero.key? :minute
    drop_zero[:second] = drop_zero[:second].to_s.rjust(2, '0') if drop_zero.key? :second
    drop_zero
  end

  def step(now: Time.current, after: 0, step: 15, skip: false)
    if after != 0
      now = after.hours.since.change(min: 0)
    end
    min = now.to_fs(:minute).to_i
    hour = now.to_fs(:hour).to_i
    r = (min..60).select(&->(i){ i % step == 0 })
    r.shift if skip && min % step != 0
    if min % step == 0
      r1 = r[0..-2]
      r2 = r[1..-1]
    elsif r.present?
      r1 = r[0..-2].prepend(min)
      r2 = r
    else
      return []
    end

    r1.map!(&->(i){ "#{hour.to_s.rjust(2, '0')}:#{i.to_s.rjust(2, '0')}" })
    r2.map!(&->(i){ i == 60 ? "#{(hour + 1).to_s.rjust(2, '0')}:00" : "#{hour.to_s.rjust(2, '0')}:#{i.to_s.rjust(2, '0')}" })

    r1.zip(r2)
  end

  def interval(start_at, finish_at, interval_start: '12:30', since: 1.hour)
    return 0 if start_at.blank? || finish_at.blank? || start_at >= finish_at
    raise 'Must be same day!' if start_at.to_date != finish_at.to_date

    hour, min = interval_start.split(':')
    interval_start_at = start_at.change hour: hour, min: min
    interval_finish_at = interval_start_at.since(since)

    if start_at < interval_start_at && finish_at > interval_finish_at
      seconds = ((finish_at - start_at) - since).to_i
    elsif start_at < interval_start_at && finish_at >= interval_start_at && finish_at <= interval_finish_at
      seconds = interval_start_at - start_at
    elsif start_at >= interval_start_at && start_at <= interval_finish_at && finish_at > interval_finish_at
      seconds = finish_at - interval_finish_at
    elsif start_at >= interval_start_at && start_at <= interval_finish_at && finish_at <= interval_finish_at
      seconds = 0
    else
      seconds = finish_at - start_at
    end
    seconds
  end

end
