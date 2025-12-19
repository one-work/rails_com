module Com
  class ErrBot < ApplicationRecord
    include Model::ErrBot
    include Inner::Bot
  end
end
