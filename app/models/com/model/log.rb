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
      attribute :session_id, :string
      attribute :user_agent, :string, as: "headers#>>'{USER_AGENT}'", virtual: true
      attribute :format, :string
      attribute :commit_uuid, :string
    end

  end
end
