# frozen_string_literal: true
module Com
  module Model::DetectorLog::DetectorResponse
    extend ActiveSupport::Concern

    included do
      after_create_commit :send_notice_later, if: -> { spend > 3000 }
    end

    def send_notice_later
      DetectorErrorJob.perform_later(self)
    end

    def send_notice
      detector_bots.map do |bot|
        bot.send_err_message("#{detector.url}请求超过 3 秒, 实际用时 #{spend} 毫秒", {
          '应用名称' => detector.name
        })
      end
    end

  end
end
