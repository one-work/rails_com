# frozen_string_literal: true

class EventJsonSubscriber

  def initialize
    @queue = Concurrent::Array.new
    Concurrent::TimerTask.execute(execution_interval: 2) { flush! }
  end

  def emit(event)
    payload = event.payload

    @queue << [
      payload[:uuid],
      payload[:controller],
      payload[:action],
      payload[:params],
      payload[:format],
      payload[:timestamp]
    ]
  end

  private
  def flush!
    return if @queue.empty?
    buf = @queue.shift(@queue.size)
    uuid = SecureRandom.uuid

    conn = ActiveRecord::Base.connection.raw_connection
    conn.copy_data 'COPY com_logs(uuid, controller_name, action_name, params, format, created_at, commit_uuid) FROM STDIN' do
      buf.each do |item|
        conn.put_copy_data item.join("\t") + "\t" + uuid + "\n"
      end
    end
  end
end