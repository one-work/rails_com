require 'test_helper'
module Com
  class Panel::AttachmentsControllerTest < ActionDispatch::IntegrationTest

    setup do
      @blob_default = com_blob_defaults(:one)
      @blob_default.file.attach io: file_fixture('empty_file.txt').open, filename: 'xx.txt'

      @active_storage_attachment = @blob_default.file.attachment
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/attachments')
      assert_response :success
    end

    test 'garbled ok' do
      get url_for(controller: 'com/panel/attachments', action: 'garbled')
      assert_response :success
    end

    test 'destroy ok' do
      assert_difference('ActiveStorage::Attachment.count', -1) do
        delete url_for(controller: 'com/panel/attachments', action: 'destroy', id: @active_storage_attachment.id), as: :turbo_stream
      end
    end

  end
end
