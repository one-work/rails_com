module Com
  class MetaAction < ApplicationRecord
    include Model::MetaAction
    include Roled::Ext::MetaAction
  end
end
