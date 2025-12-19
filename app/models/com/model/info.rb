# frozen_string_literal: true
module Com
  module Model::Info
    extend ActiveSupport::Concern

    included do
      attribute :code, :string
      attribute :value, :string
      attribute :version, :string

      enum :platform, {
        ios: 'ios',
        android: 'android'
      }

      validates :code, presence: true
    end

    class_methods do

      def verbose(q_params = nil)
        r = Info.default_where(q_params).as_json(only: [:code, :value])
        result = {}
        r.map { |i| result[i['code']] = i['value'] }
        result
      end

    end

  end
end
