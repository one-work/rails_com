require 'test_helper'
module Com
  class VideosControllerTest < ActionDispatch::IntegrationTest

    setup do
      @blob_default = com_blob_defaults(:one)
      @blob_default.file.attach io: file_fixture('empty_file.txt').open, filename: 'xx.txt'

      @active_storage_video = @blob_default.file.attachment
    end

    test 'show ok' do
      get url_for(controller: 'com/videos', action: 'show', id: @active_storage_video.id)
      assert_response :success
    end

  end
end
