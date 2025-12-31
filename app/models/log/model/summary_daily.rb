module Log
  module Model::SummaryDaily
    extend ActiveSupport::Concern
    include Statis::Ext::Day

    included do
      attribute :duration_avg, :float
      attribute :duration_max, :float
      attribute :duration_min, :float
      attribute :total, :integer

      before_action :compute!
    end

    def compute!
      requests = Request.where(created_at: start_at .. finish_at)
      self.duration_avg = requests.average(:duration)
      self.duration_max = requests.maximun(:duration)
      self.duration_min = requests.minimum(:duration)
      self.total = requests.count
      self.save
    end

    class_methods do

      def xx

      end

    end

  end
end
