# frozen_string_literal: true
module Pg
  class Panel::BaseController < PanelController

    private
    def authenticate_by
      authenticate_or_request_with_http_digest do |username|
        Rails.app.creds.require(:pg_password)
      end
    end

    def shard_params
      shard = { shard: :default }
      shard.merge! shard: params[:shard].to_sym if params[:shard].present?
      shard
    end

  end
end
