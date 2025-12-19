module Job
  module Ext::Jobbed
    extend ActiveSupport::Concern

    included do
      attribute :job_id, :string

      has_one :job, class_name: 'SolidQueue::Job', primary_key: :job_id, foreign_key: :active_job_id
      has_many :jobs, class_name: 'SolidQueue::Job', primary_key: :job_id, foreign_key: :active_job_id
    end

  end
end
