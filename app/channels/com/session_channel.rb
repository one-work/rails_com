module Com
  class SessionChannel < ApplicationCable::Channel

    def subscribed
      verified_receiver.update online_at: Time.current, offline_at: nil
      stream_from "com:session:#{verified_receiver.id}"
    end

    def unsubscribed
      verified_receiver.update online_at: nil, offline_at: Time.current
    end

  end
end
