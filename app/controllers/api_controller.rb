class ApiController < ActionController::API
  include RailsCom::Application
  include Auth::Controller::Application if defined? RailsAuth

  protect_from_forgery with: :exception, unless: -> { json_format? }

end
