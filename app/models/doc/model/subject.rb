module Doc
  module Model::Subject
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :path_params, :json
      attribute :request_params, :json
      attribute :request_headers, :json
      attribute :request_type, :string
      attribute :request_body, :json
      attribute :response_status, :string
      attribute :response_headers, :json
      attribute :response_type, :string
      attribute :response_body, :string
      attribute :note, :string

      belongs_to :meta_action, class_name: 'Meta::Action'
    end

  end
end
