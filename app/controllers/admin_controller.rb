class AdminController < ApplicationController
  include Com::Controller::Admin
  include Org::Controller::Admin if defined? RailsOrg
end
