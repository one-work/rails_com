module Com
  module Model::Log
    extend ActiveSupport::Concern

    included do
      attribute :uuid, :string
      attribute :path, :string
      attribute :controller_name, :string
      attribute :action_name, :string
      attribute :params, :json, default: {}
      attribute :headers, :json, default: {}
      attribute :cookie, :json, default: {}
      attribute :session, :json, default: {}
      attribute :ip, :string
      attribute :user_agent, :string
      attribute :format, :string
      attribute :commit_uuid, :string
    end

  end
end
