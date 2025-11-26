module Com
  module Model::LogSummary
    extend ActiveSupport::Concern

    included do
      attribute :start_at, :datetime
      attribute :finish_at, :datetime
      attribute :kind, :string
      attribute :identifier, :string
      attribute :duration_avg, :float
      attribute :duration_max, :float
      attribute :duration_min, :float
      attribute :total, :integer

      enum :kind, {
        day: 'day',
        week: 'week',
        month: 'month'
      }, prefix: true
    end

    class_methods do

      def xx

      end

    end

  end
end
