module Com
  module Model::CacheList
    extend ActiveSupport::Concern

    included do
      attribute :path, :string
      attribute :key, :string
    end

    def etag

    end

  end
end
