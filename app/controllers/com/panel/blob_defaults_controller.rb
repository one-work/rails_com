module Com
  class Panel::BlobDefaultsController < Panel::BaseController
    before_action :set_new_blob_default, only: [:add, :create]

    def sync
      BlobDefault.sync
    end

    private
    def set_new_blob_default
      @blob_default = BlobDefault.new(blob_default_params)
    end

    def blob_default_params
      params.fetch(:blob_default, {}).permit(
        :record_class,
        :name,
        :file
      )
    end

  end
end
