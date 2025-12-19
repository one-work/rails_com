class MyController < ApplicationController
  include Com::Controller::Admin
  include Trade::Controller::My if defined? RailsTrade
  before_action :require_user

end
