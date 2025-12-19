require 'test_helper'
module Com
  class Panel::BlobDefaultsControllerTest < ActionDispatch::IntegrationTest

    setup do
      @blob_default = com_blob_defaults(:one)
      @blob_default.file.attach io: file_fixture('empty_file.txt').open, filename: 'xx.txt'
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/blob_defaults')
      assert_response :success
    end

    test 'new ok' do
      get url_for(controller: 'com/panel/blob_defaults', action: 'new')
      assert_response :success
    end

    test 'create ok' do
      assert_difference('Com::BlobDefault.count') do
        post(
          url_for(controller: 'com/panel/blob_defaults', action: 'create'),
          params: { blob_default: { record_class: 'User', name: 'avatar' } },
          as: :turbo_stream
        )
      end

      assert_response :success
    end

    test 'destroy ok' do
      assert_difference('Com::BlobDefault.count', -1) do
        delete url_for(controller: 'com/panel/blob_defaults', action: 'destroy', id: @blob_default.id), as: :turbo_stream
      end

      assert_response :success
    end
  end
end
