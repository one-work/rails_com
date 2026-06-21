module Pg
  class Panel::PublicationsController < Panel::BaseController
    before_action :set_tables
    before_action :set_publication, only: [:show, :edit, :update, :destroy]

    def index
      @publications = Publication.page(params[:page])
    end

    def prod
      BaseRecord.connected_to database: { writing: :prod, reading: :prod }
      @publications = Publication.page(params[:page])
      render :index
    end

    def new
      @publication = Publication.new
    end

    def create
      allow_tables = @tables & publication_params[:tables].compact_blank!
      Publication.connection.exec_query "CREATE PUBLICATION #{publication_params[:pubname]} FOR TABLE #{allow_tables.join(', ')}"
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
      allow_tables = @tables & publication_params[:tables].compact_blank!
      Publication.connection.exec_query "ALTER PUBLICATION #{@publication.pubname} SET TABLE #{allow_tables.join(', ')}"
    end

    private
    def set_tables
      @tables = ApplicationRecord.connection.tables
    end

    def set_publication
      @publication = Publication.find(params[:id])
    end

    def publication_params
      params.fetch(:publication, {}).permit(
        :pubname,
        tables: []
      )
    end

  end
end
