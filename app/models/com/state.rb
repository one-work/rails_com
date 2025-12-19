module Com
  class State < ApplicationRecord
    include Model::State
    include Ext::Taxon
  end
end
