class BoardController < ApplicationController
  include Com::Controller::Board
  before_action :require_user

end
