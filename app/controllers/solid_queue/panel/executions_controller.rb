# frozen_string_literal: true
module Job
  class Panel::ExecutionsController < Panel::BaseController
    before_action :set_execution, only: [:show, :perform]
    before_action :set_job_classes, only: [:index, :scheduled, :running]

    def index
      @executions = GoodJob::ActiveJobJob.finished.default_where(q_params).order(finished_at: :desc).page(params[:page])
    end

    def scheduled
      @executions = GoodJob::ActiveJobJob.scheduled.default_where(q_params).order(scheduled_at: :desc).page(params[:page])
    end

    def running
      @executions = GoodJob::ActiveJobJob.running.default_where(q_params).order(scheduled_at: :desc).page(params[:page])
    end

    def show
    end

    def perform
      @execution.perform
    end

    def destroy
      deleted_count = GoodJob::Execution.where(id: params[:id]).delete_all
      message = deleted_count.positive? ? { notice: "Job execution deleted" } : { alert: "Job execution not deleted" }
      redirect_back fallback_location: root_path, **message
    end

    private
    def q_params
      q = {}
      q.merge! 'serialized_params/job_class' => params[:job_class] if params[:job_class].present?
    end

    def set_execution
      @execution = GoodJob::Execution.find_by active_job_id: params[:id]
    end

    def set_job_classes
      @job_classes = GoodJob::Execution.group("serialized_params->>'job_class'").count
    end

  end
end
