module Com
  class ErrFirstJob < ApplicationJob
    queue_as :default

    def perform(err)
      err.send_first_message
    end

  end
end
