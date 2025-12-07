module Com
  class Panel::BlobsController < Panel::BaseController
    before_action :set_blob, only: [:show, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :key, :filename, :content_type)

      @blobs = ActiveStorage::Blob.includes(:attachments).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def unattached
      q_params = {}
      q_params.merge! params.permit(:id, :key, :filename, :content_type)

      @blobs = ActiveStorage::Blob.unattached.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @blob = ActiveStorage::Blob.new(filename: '')
    end

    def create
      @blob = ActiveStorage::Blob.create_and_upload!(io: blob_params[:io].tempfile, filename: blob_params[:io].original_filename)

      unless @blob.persisted?
        render :new, locals: { model: @blob }, status: :unprocessable_entity
      end
    end

    def destroy
      @blob.purge
    end

    private
    def set_blob
      @blob = ActiveStorage::Blob.find(params[:id])
    end

    def blob_params
      params.fetch(:blob, {}).permit(*blob_permit_params)
    end

    def blob_permit_params
      [
        :key,
        :io
      ]
    end

  end
end
