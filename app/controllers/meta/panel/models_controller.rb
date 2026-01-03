module Meta
  class Panel::ModelsController < Panel::BaseController
    before_action :set_new_model, only: [:new, :create]
    before_action :set_model, only: [
      :show, :edit, :update, :destroy, :actions,
      :reflections, :indexes, :index_edit, :index_update
    ]
    before_action :set_business_identifiers, only: [:index]

    def index
      q_params = {}
      q_params.merge! params.permit(:business_identifier, :table_name, :record_name)

      @models = Model.default_where(q_params).order(record_name: :asc).page(params[:page])
    end

    def sync
      Model.sync
    end

    def options
      @models = Model.where(business_identifier: params.dig(params[:dom_scope], :business))
    end

    def columns
      @columns = Column.where(record_name: params.dig(params[:dom_scope], :record_name))
    end

    def indexes
      @indexes = @model.record_class.indexes_by_db
    end

    def index_edit
      @index = @model.record_class.indexes_by_db
    end

    def index_update
      @model.record_class.rename_index(params[:old_index], params[:new_index])
    end

    private
    def set_model
      @model = Model.find(params[:id])
    end

    def set_new_model
      @model = Model.new(model_params)
    end

    def set_business_identifiers
      @business_identifiers = Model.select(:business_identifier).distinct
    end

    def model_permit_params
      [
        :name,
        :record_name,
        :description
      ]
    end

  end
end
