# frozen_string_literal: true

Date::DATE_FORMATS[:month_and_day] = '%m-%d'
Date::DATE_FORMATS[:year_and_month] = '%Y-%m'
Date::DATE_FORMATS[:week] = ->(date) {
  I18n.t('date.day_names')[date.wday]
}
Date::DATE_FORMATS[:month] = ->(date) {
  I18n.t('date.month_names')[date.month]
}
Date::DATE_FORMATS[:year_month] = '%Y年%m月'
Date::DATE_FORMATS[:month_day] = ->(date) {
  "#{date.month}月#{date.mday}日"
}
