module Meta
  class Action < BaseRecord
    include Model::Action
    include Roled::Ext::MetaAction
  end
end
