module Com
  class Panel::PgPublicationsController < Panel::BaseController
    before_action :set_tables
    before_action :set_pg_publication, only: [:show, :edit, :update, :destroy]

    def index
      @pg_publications = PgPublication.page(params[:page])
    end

    def new
      @pg_publication = PgPublication.new
    end

    def create
      allow_tables = @tables & pg_publication_params[:tables].compact_blank!
      PgPublication.connection.exec_query "CREATE PUBLICATION #{pg_publication_params[:pubname]} FOR TABLE #{allow_tables.join(', ')}"
    end

    def create_all
      all_tables = PgPublication.connection.tables - RailsCom::Models.ignore_tables - [
        'com_errs',
        'com_logs',
        'com_err_summaries',
        'com_states',
        'com_state_hierarchies'
      ]

      PgPublication.connection.exec_query "CREATE PUBLICATION #{params[:pubname]} FOR TABLE #{all_tables.join(', ')}"
    end

    def update
      allow_tables = @tables & pg_publication_params[:tables].compact_blank!
      PgPublication.connection.exec_query "ALTER PUBLICATION #{@pg_publication.pubname} SET TABLE #{allow_tables.join(', ')}"
    end

    private
    def set_tables
      @tables = ApplicationRecord.connection.tables
    end

    def set_pg_publication
      @pg_publication = PgPublication.find(params[:id])
    end

    def pg_publication_params
      params.fetch(:pg_publication, {}).permit(
        :pubname,
        tables: []
      )
    end

  end
end
