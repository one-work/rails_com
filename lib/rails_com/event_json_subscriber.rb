# frozen_string_literal: true

class EventJsonSubscriber
  FLUSH = 1.second

  def initialize
    @queue = Concurrent::Array.new
    Concurrent::TimerTask.new(execution_interval: FLUSH) { flush! }.execute
  end

  def emit(event)
    @queue << [event[:payload][:controller], event[:payload][:action], event[:payload][:format], event[:timestamp]]
  end

  private
  def flush!
    return if @queue.empty?
    buf = @queue.shift(@queue.size)

    conn = ActiveRecord::Base.connection.raw_connection
    conn.copy_data "COPY com_logs(controller_name, action_name, format, created_at) FROM STDIN WITH (FORMAT binary)" do
      buf.each do |item|
        # 二进制格式：level(1B) + msg_len + msg + timestamp(8B)
        conn.put_copy_data item.pack('a*' * n + 'Q<')
      end
    end
  end
end