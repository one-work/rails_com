module Log
  module Model::SummaryDaily
    extend ActiveSupport::Concern
    include Statis::Ext::Day

    included do
      attribute :duration_avg, :float
      attribute :duration_max, :float
      attribute :duration_min, :float
      attribute :total, :integer

      before_create :compute
    end

    def compute
      requests = Request.where(created_at: time_range)
      self.duration_avg = requests.average(:duration).round(2)
      self.duration_max = requests.maximum(:duration)
      self.duration_min = requests.minimum(:duration)
      self.total = requests.count
    end

  end
end
