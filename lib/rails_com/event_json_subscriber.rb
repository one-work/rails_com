# frozen_string_literal: true

class EventJsonSubscriber
  COLUMNS = [
    :uuid, :controller_name, :action_name, :params, :headers, :session, :ip, :format, :session_id, :created_at
  ]

  def initialize
    @queue = Concurrent::Array.new
    Concurrent::TimerTask.execute(execution_interval: 5) { flush! }
  end

  def emit(event)
    payload = event[:payload]

    @queue << payload.values_at(*COLUMNS)
  end

  private
  def flush!
    return if @queue.empty?
    buf = @queue.shift(@queue.size)
    uuid = SecureRandom.uuid

    conn = ActiveRecord::Base.connection.raw_connection
    conn.copy_data "COPY com_logs(#{COLUMNS.join(', ')}, commit_uuid) FROM STDIN" do
      buf.each do |item|
        conn.put_copy_data item.join("\t") + "\t" + uuid + "\n"
      end
    end
  end
end