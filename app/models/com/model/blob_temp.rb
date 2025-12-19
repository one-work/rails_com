# frozen_string_literal: true
module Com
  module Model::BlobTemp
    extend ActiveSupport::Concern

    included do
      attribute :note, :string

      has_one_attached :file
    end

    def url
      file.url
    end

  end
end
