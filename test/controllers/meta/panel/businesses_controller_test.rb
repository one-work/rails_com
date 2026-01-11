require 'test_helper'
module Meta
  class Panel::BusinessesControllerTest < ActionDispatch::IntegrationTest

    setup do
      @business = MetaBusiness.first
      @namespace = MetaNamespace.first
    end

    test 'update ok' do
      patch(
        url_for(controller: 'com/panel/meta_businesses', action: 'update', id: @business.id),
        params: { meta_business: { name: 'xx' } },
        as: :turbo_stream
      )

      @namespace.reload
      assert_equal 'xx', @namespace.name
      assert_response :success
    end

  end
end
