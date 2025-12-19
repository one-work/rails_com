# frozen_string_literal: true

Time::DATE_FORMATS[:human] = '%Y-%m-%d %H:%M:%S'
Time::DATE_FORMATS[:datetime] = '%Y-%m-%d %H:%M'
Time::DATE_FORMATS[:local] = '%Y-%m-%dT%H:%M:%S'
Time::DATE_FORMATS[:with_usec] = '%Y-%m-%d %H:%M:%S.%6N'
Time::DATE_FORMATS[:wechat] = '%Y年%-m月%-d日 %H:%M'
Time::DATE_FORMATS[:hour] = '%H'
Time::DATE_FORMATS[:minute] = '%M'
Time::DATE_FORMATS[:week] = ->(time) {
  I18n.t('date.day_names')[time.wday]
}
Time::DATE_FORMATS[:date] = ->(time) {
  t = Time.zone.at time
  t.strftime '%Y-%m-%d'
}
Time::DATE_FORMATS[:month] = ->(time) {
  I18n.t('date.month_names')[time.month]
}
Time::DATE_FORMATS[:shorter] = ->(time) {
  t = Time.zone.at time
  if t.to_date == Date.today
    t.strftime '%H:%M'
  else
    t.strftime '%m-%d'
  end
}
