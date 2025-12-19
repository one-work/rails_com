module Com
  class DetectorBot < ApplicationRecord
    include Model::DetectorBot
    include Inner::Bot
  end
end
