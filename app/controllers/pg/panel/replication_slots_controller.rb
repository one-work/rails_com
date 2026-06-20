module Pg
  class Panel::ReplicationSlotsController < Panel::BaseController

    def index
      @replication_slots = ReplicationSlot.page(params[:page])
    end

  end
end
