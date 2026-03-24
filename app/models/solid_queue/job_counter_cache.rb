module SolidQueue
  class JobCounterCache < ApplicationRecord
    include Statis::Ext::Config

    attribute :queue_name, :string

    def sum_columns
      {
        index: ->(o) { o.finished.count },
        failed: ->(o) { o.failed.count },
        todo: ->(o) { o.todo.count },
        blocked: ->(o) { o.blocked.count },

        clearable: ->(o) { o.clearable.count }
      }
    end

  end
end
