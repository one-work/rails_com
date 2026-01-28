class ApiController < ActionController::API
  protect_from_forgery with: :exception, unless: -> { json_format? }

end
