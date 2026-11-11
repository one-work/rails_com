module Log
  class CleanJob < ApplicationJob

    def perform
      Request.where(created_at: ...1.months.ago.beginning_of_day).delete_all
      Query.where(created_at: ...1.months.ago.beginning_of_day).delete_all
    end

  end
end
