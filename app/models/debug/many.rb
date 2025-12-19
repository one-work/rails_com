module Debug
  class Many < ApplicationRecord
    include Model::Base
    include Model::Many
  end
end
