module Com
  class Panel::MetaNamespacesController < Panel::BaseController
    before_action :set_meta_namespace, only: [:show, :edit, :update, :destroy]

    def index
      @meta_namespaces = MetaNamespace.order(id: :asc).page(params[:page])
    end

    def sync
      MetaNamespace.sync
    end

    private
    def set_meta_namespace
      @meta_namespace = MetaNamespace.find(params[:id])
    end

    def meta_namespace_permit_params
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
