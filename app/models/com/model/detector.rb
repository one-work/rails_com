# frozen_string_literal: true
module Com
  module Model::Detector
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :url, :string

      has_many :detector_bots
      has_many :detector_logs
      has_many :detector_errors
      has_many :detector_responses

      accepts_nested_attributes_for :detector_bots
    end

    def detect(request_url = url)
      started_at = Time.current
      r = HTTPX.get request_url

      if r.error
        self.detector_errors.create(
          started_at: started_at,
          error: r.error.to_s
        )
      elsif r.status >= 300
        self.detector_errors.create(
          started_at: started_at,
          status: r.status,
          body: r.body.to_s
        )
      else
        now = Time.current
        self.detector_responses.create(
          started_at: started_at,
          status: r.status,
          spend: (now - started_at) * 1000,
          body: r.body.to_s
        )
      end
    end

  end
end
