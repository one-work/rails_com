module Meta
  class Action < ApplicationRecord
    include Model::Action
    include Roled::Ext::MetaAction
  end
end
