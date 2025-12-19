module Com
  class Panel::PumaController < Panel::BaseController
    before_action :set_puma

    def stats
      res = HTTPX.get 'http://0.0.0.0:9293/stats'
      @stats = res.json
    end

    def thread_stats
      launcher = @puma.instance_variable_get(:@launcher)
      @backtraces = []
      launcher.thread_status do |name, backtrace|
        @backtraces << { name: name, backtrace: backtrace }
      end
    end

    private
    def set_puma
      @puma = Puma.instance_variable_get(:@get_stats)
    end

  end
end
