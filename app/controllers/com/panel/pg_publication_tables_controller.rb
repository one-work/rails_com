module Com
  class Panel::PgPublicationTablesController < Panel::BaseController
    before_action :set_pg_publication

    def index
      q_params = {
        'tablename-ll': params[:tablename]
      }

      @pg_publication_tables = @pg_publication.pg_publication_tables.default_where(q_params).page(params[:page])
    end

    private
    def set_pg_publication
      @pg_publication = PgPublication.find params[:pg_publication_id]
    end

  end
end
