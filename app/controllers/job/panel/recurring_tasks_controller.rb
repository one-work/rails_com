# frozen_string_literal: true
module Job
  class Panel::RecurringTasksController < Panel::BaseController
    before_action :set_recurring_task, only: [:show, :enqueue]

    def index
      @recurring_tasks = SolidQueue::RecurringTask.all
    end

    def enqueue
      @recurring_task.enqueue(at: Time.current)
    end
  
    private
    def set_recurring_task
      @recurring_task = SolidQueue::RecurringTask.find(params[:id])
    end

  end
end
