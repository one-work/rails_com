module Com
  class ErrJob < ApplicationJob
    queue_as :default

    def perform(err)
      err.send_message
    end

  end
end
