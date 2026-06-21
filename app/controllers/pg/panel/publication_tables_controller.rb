module Pg
  class Panel::PublicationTablesController < Panel::BaseController

    def index
      q_params = {
        'tablename-ll': params[:tablename]
      }

      BaseRecord.connected_to(**shard_params) do
        @publication = Publication.find params[:publication_id]
        @publication_tables = @publication.publication_tables.default_where(q_params).page(params[:page])
      end
    end

  end
end
