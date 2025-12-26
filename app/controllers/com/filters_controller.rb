module Com
  class FiltersController < BaseController
    before_action :set_new_filter, only: [:new, :create, :detect]

    def detect
    end

    def column
      @record_class = params[:record_name].safe_constantize
    end

    def column_single
      column_name = params[:column_name].delete_suffix('-lte').delete_suffix('-gte')

      if params[:scope].present?
        @column_name = "#{params[:scope]}[#{params[:column_name]}]"
      else
        @column_name = params[:column_name]
      end
      @record_class = params[:record_name].safe_constantize
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
