module Meta
  class Panel::RecordsController < Panel::BaseController
    before_action :set_new_record, only: [:new, :create]
    before_action :set_record, only: [
      :show, :edit, :update, :destroy, :actions,
      :reflections, :indexes, :index_edit, :index_update
    ]
    before_action :set_business_identifiers, only: [:index]

    def index
      q_params = {}
      q_params.merge! params.permit(:business_identifier, :table_name, :record_name)

      @records = Record.default_where(q_params).order(record_name: :asc).page(params[:page])
    end

    def sync
      Record.sync
    end

    def options
      @records = Record.where(business_identifier: params.dig(params[:dom_scope], :business))
    end

    def columns
      @columns = Column.where(record_name: params.dig(params[:dom_scope], :record_name))
    end

    def indexes
      @indexes = @record.record_class.indexes_by_db
    end

    def index_edit
      @index = @record.record_class.indexes_by_db
    end

    def index_update
      @record.record_class.rename_index(params[:old_index], params[:new_index])
    end

    private
    def set_record
      @record = Record.find(params[:id])
    end

    def set_new_record
      @record = Record.new(record_params)
    end

    def set_business_identifiers
      @business_identifiers = Record.select(:business_identifier).distinct
    end

    def record_permit_params
      [
        :name,
        :record_name,
        :description
      ]
    end

  end
end
