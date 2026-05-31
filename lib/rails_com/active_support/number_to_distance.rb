# frozen_string_literal: true

module ActiveSupport
  module NumberHelper

    class NumberToDistanceConverter < NumberToHumanSizeConverter
      STORAGE_UNITS = [:m, :km].freeze

      private
      def conversion_format
        I18n.translate('human.distance_units.format', scope: :number, locale: options[:locale], raise: true)
      end

      def unit
        I18n.translate(storage_unit_key, scope: :number, locale: options[:locale], count: number / base, raise: true)
      end

      def storage_unit_key
        key_end = smaller_than_base? ? "m" : STORAGE_UNITS[exponent]
        "human.distance_units.units.#{key_end}"
      end

      def exponent
        max = STORAGE_UNITS.size - 1
        exp = (Math.log(number.abs) / Math.log(base)).to_i
        exp = max if exp > max # avoid overflow for the highest unit
        exp
      end

      def base
        1000
      end

    end
  end
end

module RailsCom
  module NumberToDistance

    def to_distance(options = {})
      ActiveSupport::NumberHelper::NumberToDistanceConverter.convert(self, options)
    end

  end
end

Integer.include RailsCom::NumberToDistance
Float.include RailsCom::NumberToDistance
BigDecimal.include RailsCom::NumberToDistance