# frozen_string_literal: true
module Com
  class BlobTempsController < BaseController
    before_action :set_new_blob_temp, only: [:create]
    skip_forgery_protection only: [:create]

    def create
      x = request.body.read
      content = x.split('base64,')[-1]

      @blob_temp.file.attach(
        io: StringIO.new(Base64.decode64(content)),
        filename: 'test'
      )
      @blob_temp.save

      render json: { url: @blob_temp.file.url }
    end

    private
    def set_new_blob_temp
      @blob_temp = BlobTemp.new
    end

  end
end
