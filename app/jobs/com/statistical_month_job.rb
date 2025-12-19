module Com
  class StatisticalMonthJob < ApplicationJob
    queue_as :statistic

    def perform(statistical, year_month)
      month = Date.new(*year_month.split('-').map(&:to_i))
      statistical.cached_statistic_year(start: month, finish: month.end_of_month)
    end

  end
end
