module Debug
  class Much < ApplicationRecord
    include Model::Base
    include Model::Much
  end
end
