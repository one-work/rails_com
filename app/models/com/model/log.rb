# 这个类不要有 ruby 相关回调，因为数据都是用 copy 直接快速插入进pg 数据库的
module Com
  module Model::Log
    extend ActiveSupport::Concern
    FORMAT = /(?![^(]*\))\s+/

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
      attribute :format, :string
      attribute :commit_uuid, :string
      attribute :status, :integer
      attribute :duration, :integer
      attribute :view_duration, :float
      attribute :db_duration, :float
      attribute :query_count, :integer
      attribute :query_cached_count, :integer
      attribute :user_agent, :string, as: "headers#>>'{USER_AGENT}'", virtual: true
      attribute :accept, :string, as: "headers#>>'{ACCEPT}'", virtual: true
      attribute :referer, :string, as: "headers#>>'{REFERER}'", virtual: true
      attribute :identifier, :string, as: "controller_name || '#' || action_name", virtual: true
    end

    def real_path
      URI.decode_www_form_component path
    end

    def user_agents
      user_agent.to_s.split(FORMAT).map { |i| i.delete_prefix('(').delete_suffix(')') }
    end

    def slim_headers
      headers.except('USER_AGENT', 'REFERER', 'ACCEPT')
    end

  end
end
