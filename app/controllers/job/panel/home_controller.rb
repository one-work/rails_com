module Job
  class Panel::HomeController < Panel::BaseController

    def index
      @queues = SolidQueue::Queue.all
      @processes = SolidQueue::Process.includes(:supervisees).where(supervisor_id: nil).order(created_at: :desc)
    end

  end
end
