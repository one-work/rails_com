# frozen_string_literal: true

class EventJsonSubscriber
  FLUSH = 1.second

  def initialize
    @conn = ActiveRecord::Base.connection.raw_connection
    @queue = Concurrent::Array.new
    Concurrent::TimerTask.new(execution_interval: FLUSH) { flush! }.execute
  end

  def emit(event)
    @queue << event
  end

  private
  def flush!
    return if @queue.empty?
    buf = @queue.shift(@queue.size)
    @conn.copy_data "COPY rails_logs(level,msg,created_at) FROM STDIN WITH (FORMAT binary)" do
      buf.each do |level, msg, t|
        # 二进制格式：level(1B) + msg_len + msg + timestamp(8B)
        @conn.put_copy_data [level, msg, t].pack("Z*a*Q<")
      end
    end
  end
end