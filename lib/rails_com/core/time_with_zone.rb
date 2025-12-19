require 'rails_com/core/date_and_time'

module ActiveSupport
  class TimeWithZone
    include RailsCom::DateAndTime

    def inspect
      to_fs
    end

  end
end
