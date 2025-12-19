# frozen_string_literal: true

module Jobber
  extend self

  def deliver(job, *arguments)
    msg = job_data(job, arguments)

    r = redis_pool.with do |conn|
      conn.pipelined do
        conn.lpush(queue_key, JSON.dump(msg))
        conn.lrange(queue_key, 0, 0)
      end
    end
    JSON.load(r[1].first)
  end

  def job_data(job, args, at: nil)
    {
      class: 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
      wrapped: job,
      queue: config['queue'],
      args: [ {
        job_class: job,
        job_id: SecureRandom.uuid,
        queue_name: config['queue'],
        priority: nil,
        arguments: args,
        locale: 'en'
      } ],
      retry: true,
      jid: SecureRandom.hex(12),
      created_at: Time.now.to_f,
      enqueued_at: Time.now.to_f
    }
  end

  def rjobs(size = 1)
    result = redis_pool.with do |conn|
      conn.lrange(queue_key, -size, -1)
    end
    result.map do |r|
      JSON.load(r)
    end
  end

  def ljobs(size = 1)
    result = redis_pool.with do |conn|
      conn.lrange(queue_key, 0, size - 1)
    end
    result.map do |r|
      JSON.load(r)
    end
  end

  def queue_key
    @queue_key ||= "queue:#{config['queue']}"
  end

  def redis_pool
    @redis_pool ||= ConnectionPool.new(size: 5, timeout: 5) { Redis.new(url: config['url']) }
  end

  def redis
    Redis.new(url: config['url'])
  end

  def config
    @config ||= Rails.application.config_for('jobber')
  end

end
