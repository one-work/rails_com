module Job
  module Model::Queue
    extend ActiveSupport::Concern

    included do
      scope :todo, -> { scheduled.where(scheduled_at: Time.current..) }
      scope :blocked, -> { associated(:blocked_execution) }
      scope :running, -> { associated(:claimed_execution) }
      scope :ready, -> { associated(:ready_execution) }
    end

  end
end
