module Debug
  class One < ApplicationRecord
    include Model::Base
    include Model::One
  end
end
