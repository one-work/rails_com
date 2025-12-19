module Com
  class Panel::DetectorLogsController < Panel::BaseController
    before_action :set_detector

    def index
      @detector_logs = @detector.detector_logs.order(id: :desc).page(params[:page])
    end

    private
    def set_detector
      @detector = Detector.find params[:detector_id]
    end

  end
end
