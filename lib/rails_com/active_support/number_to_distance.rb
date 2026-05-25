# frozen_string_literal: true

module ActiveSupport
  module NumberHelper

    eager_autoload do
      autoload :NumberToDistanceConverter
    end

    class NumberToDistanceConverter < NumberToHumanSizeConverter
      STORAGE_UNITS = [:m, :km].freeze
      
      private
      def base
        1000
      end

    end
  end
end

module RailsCom
  module NumberToDistance

    def to_distance
      NumberToDistanceConverter.convert(self, options)
    end

  end
end

ActiveSupport::NumericWithFormat.include RailsCom::NumberToDistance
