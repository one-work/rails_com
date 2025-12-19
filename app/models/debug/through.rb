module Debug
  class Through < ApplicationRecord
    include Model::Base
    include Model::Through
  end
end
