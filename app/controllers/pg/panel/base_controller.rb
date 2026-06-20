# frozen_string_literal: true
module Pg
  class Panel::BaseController < PanelController

    private
    def authenticate_by
      authenticate_or_request_with_http_digest do |username|
        Rails.app.credentials.pg_password
      end
    end

  end
end
