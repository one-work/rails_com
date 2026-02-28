module Roled
  module Model::Tab
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :path, :string
      attribute :icon, :string
      attribute :position, :integer
      attribute :namespace, :string

      belongs_to :role

      positioned on: [:role_id]
    end

    def real_path
      if Rails.app.config.relative_url_root.present?
        "#{Rails.app.config.relative_url_root}/#{path}"
      else
        path
      end
    end

  end
end
