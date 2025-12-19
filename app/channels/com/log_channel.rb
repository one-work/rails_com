module Com
  class LogChannel < ApplicationCable::Channel

    def subscribed
      stream_from "com:log:#{verified_receiver.id}"
    end

    def self.push_log(auth_token)
      broadcast_to(auth_token, 'd')
    end

  end
end
