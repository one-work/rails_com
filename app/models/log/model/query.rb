# 这个类不要有 ruby 相关回调，因为数据都是用 copy 直接快速插入进pg 数据库的
module Log
  module Model::Query
    extend ActiveSupport::Concern

    included do
      attribute :uuid, :string
      attribute :commit_uuid, :string
      attribute :name, :string
      attribute :async, :boolean
      attribute :sql, :string
      attribute :duration, :float
    end

    class_methods do

      def init_stats(day: Date.yesterday)
        day.prev_month.upto(day) do |date|
          QueryDailyJob.perform_now(date)
        end
      end

    end

  end
end
