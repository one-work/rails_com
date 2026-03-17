module Statis
  class ConfigCacheJob < ApplicationJob
    queue_as :statistic

    def perform(counter)
      counter.compute!
    end

  end
end
