module Job
  module Model::Queue
    extend ActiveSupport::Concern

    included do
      scope :todo, -> { scheduled.where(scheduled_at: Time.current..) }
      scope :blocked, -> { where.associated(:blocked_execution) }
      scope :running, -> { where.associated(:claimed_execution) }
      scope :ready, -> { where.associated(:ready_execution) }
    end

  end
end
