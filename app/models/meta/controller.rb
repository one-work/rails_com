module Meta
  class Controller < ApplicationRecord
    include Model::Controller
    include Roled::Ext::MetaController
  end
end
