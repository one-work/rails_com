module Meta
  class Panel::ColumnsController < Panel::BaseController
    before_action :set_model
    before_action :set_new_column, only: [:new, :create]
    before_action :set_column, only: [:show, :edit, :update, :destroy, :sync, :test]

    def index
      @columns = @model.columns.page(params[:page])
    end

    def sync
      @column.sync
    end

    def test
      @column.test
    end

    private
    def set_model
      @model = MetaModel.find params[:model_id]
    end

    def set_column
      @column = @model.columns.find(params[:id])
    end

    def set_new_column
      @column = @model.columns.build(column_params)
    end

    def column_params
      params.fetch(:column, {}).permit(*column_permit_params)
    end

    def column_permit_params
      [
        :model_name,
        :column_name,
        :column_type,
        :sql_type,
        :column_limit
      ]
    end

  end
end
