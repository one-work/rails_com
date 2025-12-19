module Com
  class Panel::MetaColumnsController < Panel::BaseController
    before_action :set_meta_model
    before_action :set_new_meta_column, only: [:new, :create]
    before_action :set_meta_column, only: [:show, :edit, :update, :destroy, :sync, :test]

    def index
      @meta_columns = @meta_model.meta_columns.page(params[:page])
    end

    def sync
      @meta_column.sync
    end

    def test
      @meta_column.test
    end

    private
    def set_meta_model
      @meta_model = MetaModel.find params[:meta_model_id]
    end

    def set_meta_column
      @meta_column = @meta_model.meta_columns.find(params[:id])
    end

    def set_new_meta_column
      @meta_column = @meta_model.meta_columns.build(meta_column_params)
    end

    def meta_column_params
      params.fetch(:meta_column, {}).permit(*meta_column_permit_params)
    end

    def meta_column_permit_params
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
