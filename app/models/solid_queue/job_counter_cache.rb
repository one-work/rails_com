module SolidQueue
  class JobCounterCache < ApplicationRecord
    include Statis::Ext::Config

    attribute :state, :string
    attribute :payment_status, :string

    def sum_columns
      {
        index: ->(o) { o.finished.count },
        failed: ->(o) { o.failed.count },
        todo: ->(o) { o.todo.count },
        blocked: ->(o) { o.blocked.count },
        running: ->(o) { o.running.count },
        ready: ->(o) { o.ready.count },
        clearable: ->(o) { o.clearable.count }
      }
    end

  end
end
