module Com
  class Panel::PgReplicationSlotsController < Panel::BaseController

    def index
      @pg_replication_slots = PgReplicationSlot.page(params[:page])
    end

  end
end
