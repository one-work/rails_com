module SolidQueue
  class Panel::HomeController < Panel::BaseController

    def index
      @queues = Queue.all
      @processes = Process.includes(:supervisees).where(supervisor_id: nil).order(created_at: :desc)
    end

  end
end
