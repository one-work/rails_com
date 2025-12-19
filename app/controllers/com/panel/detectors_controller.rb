module Com
  class Panel::DetectorsController < Panel::BaseController
    before_action :set_detector, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_detector, only: [:new, :create]

    def new
      @detector.detector_bots.build
    end

    def edit
      @detector.detector_bots.build if @detector.detector_bots.blank?
    end

    private
    def set_detector
      @detector = Detector.find params[:id]
    end

    def set_new_detector
      @detector = Detector.new(detector_params)
    end

    def detector_params
      params.fetch(:detector, {}).permit(
        :name,
        :url,
        detector_bots_attributes: {}
      )
    end

  end
end
