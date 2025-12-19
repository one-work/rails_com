require 'test_helper'
module Com
  class Panel::InboundEmailsControllerTest < ActionDispatch::IntegrationTest

    setup do
      @inbound_email = ActionMailbox::InboundEmail.create_and_extract_message_id! file_fixture('welcome.eml').read
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/inbound_emails')
      assert_response :success
    end

    test 'show ok' do
      get url_for(controller: 'com/panel/inbound_emails', action: 'show', id: @inbound_email.id)
      assert_response :success
    end

    test 'destroy ok' do
      assert_difference('ActionMailbox::InboundEmail.count', -1) do
        delete url_for(controller: 'com/panel/inbound_emails', action: 'destroy', id: @inbound_email.id), as: :turbo_stream
      end

      assert_response :success
    end

  end
end
