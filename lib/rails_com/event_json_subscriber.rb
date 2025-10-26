# frozen_string_literal: true

class EventJsonSubscriber
  FLUSH = 5.second

  def initialize
    @queue = Concurrent::Array.new
    Rails.logger.debug "---------------------初始化 ---#{}----"
    Concurrent::TimerTask.new(execution_interval: FLUSH) { flush! }.execute
  end

  def emit(event)
    @queue << [
      event[:payload][:controller],
      event[:payload][:action],
      event[:payload][:format].to_s,
      event[:payload][:timestamp]
    ]
  end

  private
  def flush!
    return if @queue.empty?
    buf = @queue.shift(@queue.size)

    Rails.logger.debug "--------------------------#{buf}"

    conn = ActiveRecord::Base.connection.raw_connection

    Rails.logger.debug "---------------------------#{conn}"
    conn.copy_data 'COPY com_logs(controller_name, action_name, format, created_at) FROM STDIN' do
      buf.each do |item|
        conn.put_copy_data item.join("\t") + "\n"
      end
    end
  end
end