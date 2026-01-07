module Meta
  class Controller < BaseRecord
    include Model::Controller
    include Roled::Ext::MetaController
  end
end
