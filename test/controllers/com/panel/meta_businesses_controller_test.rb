require 'test_helper'
module Com
  class Panel::MetaBusinessesControllerTest < ActionDispatch::IntegrationTest

    setup do
      @meta_business = MetaBusiness.first
      @meta_namespace = MetaNamespace.first
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/meta_businesses')
      assert_response :success
    end

    test 'show ok' do
      get url_for(controller: 'com/panel/meta_businesses', action: 'show', id: @meta_business.id)
      assert_response :success
    end

    test 'edit ok' do
      get url_for(controller: 'com/panel/meta_businesses', action: 'edit', id: @meta_business.id)
      assert_response :success
    end

    test 'update ok' do
      patch(
        url_for(controller: 'com/panel/meta_businesses', action: 'update', id: @meta_business.id),
        params: { meta_business: { name: 'xx' } },
        as: :turbo_stream
      )

      @meta_namespace.reload
      assert_equal 'xx', @meta_namespace.name
      assert_response :success
    end

  end
end
