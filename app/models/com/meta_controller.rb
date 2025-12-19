module Com
  class MetaController < ApplicationRecord
    include Model::MetaController
    include Roled::Ext::MetaController
  end
end
