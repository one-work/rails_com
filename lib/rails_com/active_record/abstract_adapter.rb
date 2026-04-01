# frozen_string_literal: true

module RailsCom::ActiveRecord
  module AbstractAdapter

    def truncate_tables(*table_names)
      table_names -= [
        'meta_actions',
        'meta_businesses',
        'meta_columns',
        'meta_controllers',
        'meta_namespaces',
        'meta_operations',
        'meta_records',
        'doc_maps',
        'doc_subjects',
        'solid_queue_blocked_executions',
        'solid_queue_claimed_executions',
        'solid_queue_failed_executions',
        'solid_queue_jobs',
        'solid_queue_pauses',
        'solid_queue_processes',
        'solid_queue_ready_executions',
        'solid_queue_recurring_executions',
        'solid_queue_recurring_tasks',
        'solid_queue_scheduled_executions',
        'solid_queue_semaphores'
      ]

      super
    end

  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(RailsCom::ActiveRecord::AbstractAdapter)
