# 这个类不要有 ruby 相关回调，因为数据都是用 copy 直接快速插入进pg 数据库的
module Com
  module Model::LogSql
    extend ActiveSupport::Concern

    included do
      attribute :uuid, :string
      attribute :commit_uuid, :string
      attribute :name, :string
      attribute :async, :boolean
      attribute :sql, :string
      attribute :duration, :float
    end

  end
end
