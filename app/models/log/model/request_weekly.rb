module Log
  module Model::RequestWeekly
    extend ActiveSupport::Concern
    include Statis::Ext::Week

    included do
      attribute :identifier, :string
      attribute :duration_avg, :float
      attribute :duration_max, :float
      attribute :duration_min, :float
      attribute :total, :integer

      has_many :request_dailyes, primary_key: :identifier, foreign_key: :identifier
    end

    def compute
      reqs = requests.where(created_at: time_range)
      self.duration_avg = reqs.average(:duration).round(2)
      self.duration_max = reqs.maximum(:duration)
      self.duration_min = reqs.minimum(:duration)
      self.total = reqs.count
    end

  end
end
