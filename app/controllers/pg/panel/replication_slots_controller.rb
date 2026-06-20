module Pg
  class Panel::ReplicationSlotsController < Panel::BaseController

    def index
      @pg_replication_slots = ReplicationSlot.page(params[:page])
    end

  end
end
