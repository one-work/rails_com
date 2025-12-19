# frozen_string_literal: true
module Job
  class Panel::QueuesController < Panel::BaseController
    before_action :set_queue, only: [:pause, :resume]

    def index
      @queues = SolidQueue::Queue.all
    end

    def pause
      @queue.pause
    end

    def resume
      @queue.resume
    end

    private
    def set_queue
      queues_hash = SolidQueue::Queue.all.each_with_object({}) do |queue, h|
        h.merge! queue.name => queue
      end
      @queue = queues_hash[params[:id]]
    end

  end
end
