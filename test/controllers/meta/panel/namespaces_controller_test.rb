require 'test_helper'
module Meta
  class Panel::NamespacesControllerTest < ActionDispatch::IntegrationTest

    setup do
      @namespace = MetaNamespace.first
    end

    test 'update ok' do
      patch(
        url_for(controller: 'com/panel/meta_namespaces', action: 'show', id: @namespace.id),
        params: { meta_namespace: { name: 'xx' } },
        as: :turbo_stream
      )

      @namespace.reload
      assert_equal 'xx', @namespace.name
      assert_response :success
    end

  end
end
