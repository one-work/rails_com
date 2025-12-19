module Com
  class StateDestroyJob < ApplicationJob

    def perform(id)
      State.where(id: id).delete_all
    end

  end
end
