module Pg
  class Panel::PublicationsController < Panel::BaseController
    before_action :set_tables
    before_action :set_pg_publication, only: [:show, :edit, :update, :destroy]

    def index
      @pg_publications = Publication.page(params[:page])
    end

    def prod
      BaseRecord.connects_to database: { writing: :prod, reading: :prod }
      @pg_publications = Publication.page(params[:page])
      render :index
    end

    def new
      @pg_publication = Publication.new
    end

    def create
      allow_tables = @tables & pg_publication_params[:tables].compact_blank!
      Publication.connection.exec_query "CREATE PUBLICATION #{pg_publication_params[:pubname]} FOR TABLE #{allow_tables.join(', ')}"
    end

    def create_all
      all_tables = Publication.connection.tables - RailsCom::Models.ignore_tables - [
        'log_requests',
        'log_queries',
        'com_errs',
        'com_err_summaries',
        'com_states',
        'com_state_hierarchies'
      ]

      Publication.connection.exec_query "CREATE PUBLICATION #{params[:pubname]} FOR TABLE #{all_tables.join(', ')}"
    end

    def update
      allow_tables = @tables & pg_publication_params[:tables].compact_blank!
      Publication.connection.exec_query "ALTER PUBLICATION #{@pg_publication.pubname} SET TABLE #{allow_tables.join(', ')}"
    end

    private
    def set_tables
      @tables = ApplicationRecord.connection.tables
    end

    def set_pg_publication
      @pg_publication = Publication.find(params[:id])
    end

    def pg_publication_params
      params.fetch(:pg_publication, {}).permit(
        :pubname,
        tables: []
      )
    end

  end
end
