module Com
  class Panel::BaseController < PanelController
    include ActiveStorage::SetCurrent
  end
end
