class MeController < AdminController
  include Org::Controller::Me if defined? RailsOrg

end
