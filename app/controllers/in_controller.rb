class InController < AdminController
  if defined? RailsOrg
    include Org::Controller::Me
    include Org::Controller::In
  end

end
