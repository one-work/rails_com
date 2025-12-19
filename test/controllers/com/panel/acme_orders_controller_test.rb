require 'test_helper'
module Com
  class Panel::AcmeOrdersControllerTest < ActionDispatch::IntegrationTest

    setup do
      @acme_order = com_acme_orders(:one)
      @acme_account = @acme_order.acme_account
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/acme_orders', acme_account_id: @acme_account.id)
      assert_response :success
    end

    test 'new ok' do
      get url_for(controller: 'com/panel/acme_orders', action: 'new', acme_account_id: @acme_account.id)
      assert_response :success
    end

    test 'create ok' do
      assert_difference('Com::AcmeOrder.count') do
        post(
          url_for(controller: 'com/panel/acme_orders', action: 'create', acme_account_id: @acme_account.id),
          params: { },
          as: :turbo_stream
        )
      end

      assert_response :success
    end

    test 'show ok' do
      get url_for(controller: 'com/panel/acme_orders', action: 'show', acme_account_id: @acme_account.id, id: @acme_order.id)
      assert_response :success
    end

    test 'edit ok' do
      get url_for(controller: 'com/panel/acme_orders', action: 'edit', acme_account_id: @acme_account.id, id: @acme_order.id)
      assert_response :success
    end

    test 'update ok' do
      patch(
        url_for(controller: 'com/panel/acme_orders', action: 'update', acme_account_id: @acme_account.id, id: @acme_order.id),
        params: { },
        as: :turbo_stream
      )
      assert_response :success
    end

    test 'destroy ok' do
      assert_difference('Com::AcmeOrder.count', -1) do
        delete url_for(controller: 'com/panel/acme_orders', action: 'destroy', acme_account_id: @acme_account.id, id: @acme_order.id), as: :turbo_stream
      end

      assert_response :success
    end

  end
end
