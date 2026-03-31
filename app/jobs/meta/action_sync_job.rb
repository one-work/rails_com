module Meta
  class ActionSyncJob < ApplicationJob
    queue_as :default

    def perform
      Action.sync
    end

  end
end
