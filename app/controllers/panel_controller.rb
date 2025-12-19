class PanelController < ApplicationController
  include Com::Controller::Panel
  include Roled::Controller::Panel
  include Org::Controller::Panel if defined? RailsOrg
  before_action :require_member_or_user, :require_role

end
