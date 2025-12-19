require 'test_helper'
module Com
  class Panel::BlobsControllerTest < ActionDispatch::IntegrationTest

    setup do
      @blob = active_storage_blobs(:one)
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/blobs')
      assert_response :success
    end

    test 'new ok' do
      get url_for(controller: 'com/panel/blobs', action: 'new')
      assert_response :success
    end

    test 'create ok' do
      io = Rack::Test::UploadedFile.new File.join(self.class.file_fixture_path, 'empty_file.txt')
      assert_difference('ActiveStorage::Blob.count') do
        post(
          url_for(controller: 'com/panel/blobs', action: 'create'),
          params: { blob: { io: io } },
          as: :turbo_stream
        )
      end

      assert_response :success
    end

    test 'destroy ok' do
      assert_difference('ActiveStorage::Blob.count', -1) do
        delete url_for(controller: 'com/panel/blobs', action: 'destroy', id: @blob.id), as: :turbo_stream
      end

      assert_response :success
    end
  end
end
