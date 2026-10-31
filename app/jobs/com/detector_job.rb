module Com
  class DetectorJob < ApplicationJob

    def perform
      Detector.enabled.limit(10).each do |detector|
        detector.detect
      end
    end

  end
end
