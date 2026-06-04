module Com
  class StateDestroyJob < ApplicationJob

    def perform
      State.where(destroyable: true, created_at: ..1.hour.ago).destroy_all
    end

  end
end
