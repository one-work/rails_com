module Pg
  class Panel::PublicationTablesController < Panel::BaseController
    before_action :set_publication

    def index
      q_params = {
        'tablename-ll': params[:tablename]
      }

      @publication_tables = @publication.publication_tables.default_where(q_params).page(params[:page])
    end

    private
    def set_publication
      @publication = Publication.find params[:publication_id]
    end

  end
end
