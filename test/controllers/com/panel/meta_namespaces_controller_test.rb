require 'test_helper'
module Com
  class Panel::MetaNamespacesControllerTest < ActionDispatch::IntegrationTest

    setup do
      @meta_namespace = MetaNamespace.first
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/meta_namespaces')
      assert_response :success
    end

    test 'show ok' do
      get url_for(controller: 'com/panel/meta_namespaces', action: 'show', id: @meta_namespace.id)
      assert_response :success
    end

    test 'edit ok' do
      get url_for(controller: 'com/panel/meta_namespaces', action: 'edit', id: @meta_namespace.id)
      assert_response :success
    end

    test 'update ok' do
      patch(
        url_for(controller: 'com/panel/meta_namespaces', action: 'show', id: @meta_namespace.id),
        params: { meta_namespace: { name: 'xx' } },
        as: :turbo_stream
      )

      @meta_namespace.reload
      assert_equal 'xx', @meta_namespace.name
      assert_response :success
    end

  end
end
