# frozen_string_literal: true

class EventSqlSubscriber
  COLUMNS = [
    :name, :async, :sql, :duration, :created_at
  ]

  def initialize
    @queue = Concurrent::Array.new
    @coder = PG::TextEncoder::CopyRow.new
    Concurrent::TimerTask.execute(execution_interval: 2) { flush! }
  end

  def emit(event)
    payload = event[:payload]

    @queue << [
      payload[:name],
      payload[:async],
      payload[:sql],
      payload[:duration_ms],
      Time.now.utc.iso8601(6)
    ] if payload[:duration_ms] > 10
  end

  private
  def flush!
    return if @queue.empty?
    buf = @queue.shift(@queue.size)
    uuid = SecureRandom.uuid

    conn = ActiveRecord::Base.connection.raw_connection
    conn.copy_data "COPY log_queries(#{COLUMNS.join(', ')}, commit_uuid) FROM STDIN" do
      buf.each do |item|
        conn.put_copy_data item << uuid, @coder
      end
    end
  end
end