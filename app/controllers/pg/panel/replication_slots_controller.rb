module Pg
  class Panel::ReplicationSlotsController < Panel::BaseController
    before_action :set_replication_slot, only: [:show, :destroy]

    def index
      @replication_slots = ReplicationSlot.page(params[:page])
    end

    def destroy
      unless @replication_slot.active
        ReplicationSlot.connection.exec_query "SELECT pg_drop_replication_slot('#{@replication_slot.slot_name}')"
      end
    end

    private
    def set_replication_slot
      @replication_slot = ReplicationSlot.find(params[:id])
    end

  end
end
