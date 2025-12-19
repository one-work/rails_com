module Com
  class Admin::FiltersController < Admin::BaseController
    before_action :set_new_filter, only: [:new, :create, :detect]

    def detect
    end

    def column
      @meta_column = MetaColumn.find_by(record_name: params[:record_name], column_name: params[:column_name])
    end

    def column_single
      column_name = params[:column_name].delete_suffix('-lte').delete_suffix('-gte')
      @meta_column = MetaColumn.find_by(record_name: params[:record_name], column_name: column_name)
    end

    private
    def set_new_filter
      @filter = Filter.new(filter_params)
    end

    def filter_params
      _p = params.fetch(:filter, {}).permit(
        :name,
        :controller_path,
        :action_name,
        filter_columns_attributes: [:id, :column, :value, :_destroy]
      )
      _p.merge! default_form_params
    end

  end
end
