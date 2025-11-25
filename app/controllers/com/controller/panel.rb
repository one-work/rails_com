module Com
  module Controller::Panel
    extend ActiveSupport::Concern
    include Controller::Curd

    def require_member_or_user
      require_user unless current_member
    end

    def index
      instance_variable_set "@#{pluralize_model_name}", model_klass.order(id: :asc).page(params[:page])
    end

    private
    def model_params
      if self.class.private_method_defined?("#{model_name}_params") || self.class.method_defined?("#{model_name}_params")
        send "#{model_name}_params"
      else
        params.fetch(model_name, {}).permit(
          *permit_keys,
          **model_klass.com_column_extra,
          **model_klass.com_column_hash
        )
      end
    end

  end
end
