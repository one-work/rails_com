module Pg
  class Panel::PublicationsController < Panel::BaseController
    REMOVE = [
      'log_requests', 'log_queries',
      'com_errs', 'com_err_summaries',
      'com_states', 'com_state_hierarchies',
      'meta_actions', 'meta_businesses', 'meta_columns', 'meta_controllers', 'meta_namespaces', 'meta_operations'
    ].freeze
    before_action :set_shards
    before_action :set_tables
    before_action :set_publication, only: [:show, :edit, :update, :destroy]

    def index
      BaseRecord.connected_to(**shard_params) do
        @publications = Publication.page(params[:page])
      end
    end

    def new
      @publication = Publication.new
    end

    def create
      allow_tables = @tables & publication_params[:tables].compact_blank!
      BaseRecord.connected_to(**shard_params) do
        Publication.connection.exec_query "CREATE PUBLICATION #{publication_params[:pubname]} FOR TABLE #{allow_tables.join(', ')}"
      end
    end

    def create_all
      BaseRecord.connected_to(**shard_params) do
        all_tables = Publication.connection.tables - RailsCom::Models.ignore_tables - REMOVE
        Publication.connection.exec_query "CREATE PUBLICATION #{params[:pubname]} FOR TABLE #{all_tables.join(', ')}"
      end
    end

    def update
      BaseRecord.connected_to(**shard_params) do
        allow_tables = @tables & publication_params[:tables].compact_blank!
        Publication.connection.exec_query "ALTER PUBLICATION #{@publication.pubname} SET TABLE #{allow_tables.join(', ')}"
      end
    end

    private
    def set_tables
      BaseRecord.connected_to(**shard_params) do
        @tables = ApplicationRecord.connection.tables
      end
    end

    def set_publication
      BaseRecord.connected_to(**shard_params) do
        @publication = Publication.find(params[:id])
      end
    end

    def publication_params
      params.fetch(:publication, {}).permit(
        :pubname,
        tables: []
      )
    end

  end
end
