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
    end

    class_methods do

      def xx

      end

    end

  end
end
