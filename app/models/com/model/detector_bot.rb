# frozen_string_literal: true
module Com
  module Model::DetectorBot
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :hook_url, :string

      belongs_to :detector
    end

    def set_content(err)
      err.as_json(only: [:status, :body, :error]).each do |k, v|
        add_column err.class.human_attribute_name(k), v unless v.blank?
      end
    end

  end
end
