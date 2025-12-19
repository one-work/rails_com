# frozen_string_literal: true
module Pg
  class Panel::BaseController < PanelController
    skip_before_action :require_member_or_user if whether_filter(:require_member_or_user)
    skip_before_action :require_role if whether_filter(:require_role)
    before_action :authenticate_by

    private
    def authenticate_by
      authenticate_or_request_with_http_digest do |username|
        Rails.application.credentials.pg_password
      end
    end

  end
end
