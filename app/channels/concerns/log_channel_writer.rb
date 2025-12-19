# frozen_string_literal: true

class LogChannelWriter

  def initialize(auth_token)
    @auth_token = auth_token
  end

  def << msg
    LogChannel.broadcast_to(@auth_token, msg)
  end

end