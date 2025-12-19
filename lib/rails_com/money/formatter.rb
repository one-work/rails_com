# frozen_string_literal: true
require 'money'
module RailsCom::Money

  def indent(*rules)
    Money::Formatter.new(self, *rules).whole_part.length
  end

  module Formatter

    def whole_part
      whole_part, _ = extract_whole_and_decimal_parts
      format_whole_part(whole_part)
    end

  end
end

Money.include RailsCom::Money
Money::Formatter.include RailsCom::Money::Formatter
