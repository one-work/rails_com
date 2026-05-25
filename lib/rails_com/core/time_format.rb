# frozen_string_literal: true

ActiveSupport::TimeFormats.register(:human, '%Y-%m-%d %H:%M:%S')
ActiveSupport::TimeFormats.register(:datetime, '%Y-%m-%d %H:%M')
ActiveSupport::TimeFormats.register(:local, '%Y-%m-%dT%H:%M:%S')
ActiveSupport::TimeFormats.register(:with_usec, '%Y-%m-%d %H:%M:%S.%6N')
ActiveSupport::TimeFormats.register(:wechat, '%Y年%-m月%-d日 %H:%M')
ActiveSupport::TimeFormats.register(:short_cn, '%-m月%-d日 %H:%M')
ActiveSupport::TimeFormats.register(:hour, '%H')
ActiveSupport::TimeFormats.register(:minute, '%M')
ActiveSupport::TimeFormats.register(:week, ->(time) { I18n.t('date.day_names')[time.wday] })
ActiveSupport::TimeFormats.register(:date, ->(time) { Time.zone.at(time).strftime('%Y-%m-%d') })
ActiveSupport::TimeFormats.register(:month, ->(time) { I18n.t('date.month_names')[time.month] })
ActiveSupport::TimeFormats.register(
  :shorter,
  ->(time) {
    t = Time.zone.at(time)
    if t.to_date == Date.today
      t.strftime '%H:%M'
    else
      t.strftime '%m-%d'
    end
  }
)
