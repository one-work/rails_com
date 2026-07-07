module Pg
  class Panel::PublicationTablesController < Panel::BaseController
    before_action :set_filter_columns

    def index
      q_params = {
        'tablename-ll': params[:tablename]
      }

      BaseRecord.connected_to(**shard_params) do
        @publication = Publication.find params[:publication_id]
        @publication_tables = @publication.publication_tables.default_where(q_params).page(params[:page])
      end
    end

    private
    def filter_columns
      {
        'tablename' => { type: 'search', default: true }
      }
    end

  end
end
