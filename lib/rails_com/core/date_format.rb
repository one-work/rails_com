# frozen_string_literal: true

ActiveSupport::DateFormats.register(:month_and_day, '%m-%d')
ActiveSupport::DateFormats.register(:year_and_month, '%Y-%m')
ActiveSupport::DateFormats.register(:week, ->(date) { I18n.t('date.day_names')[date.wday] })
ActiveSupport::DateFormats.register(:month, ->(date) { I18n.t('date.month_names')[date.month] })
ActiveSupport::DateFormats.register(:year_month, '%Y年%m月')
ActiveSupport::DateFormats.register(:month_day, ->(date) { "#{date.month}月#{date.mday}日" })
