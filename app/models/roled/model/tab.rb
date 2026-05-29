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

    def real_path(**options)
      if Rails.app.config.relative_url_root.present?
        url = "#{Rails.app.config.relative_url_root}/#{path}"
      else
        url = path
      end

      options.compact!
      if options.present?
        url = URI(url)
        url.query = options.to_query
      end

      url.to_s
    end

  end
end
