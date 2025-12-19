module Com
  class Panel::DetectorErrorsController < Panel::BaseController
    before_action :set_detector

    def index
      @detector_errors = @detector.detector_errors.page(params[:page])
    end

    private
    def set_detector
      @detector = Detector.find params[:detector_id]
    end

  end
end
