module Com
  class DetectorErrorJob < ApplicationJob

    def perform(error)
      error.send_notice
    end

  end
end
