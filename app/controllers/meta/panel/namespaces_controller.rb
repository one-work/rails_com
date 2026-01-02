module Meta
  class Panel::NamespacesController < Panel::BaseController
    before_action :set_namespace, only: [:show, :edit, :update, :destroy]

    def index
      @namespaces = Namespace.order(id: :asc).page(params[:page])
    end

    def sync
      Namespace.sync
    end

    private
    def set_namespace
      @namespace = Namespace.find(params[:id])
    end

    def namespace_permit_params
      [
        :name,
        :identifier,
        :verify_organ,
        :verify_member,
        :verify_user
      ]
    end

  end
end
