require 'test_helper'
module Com
  class Panel::CacheListsControllerTest < ActionDispatch::IntegrationTest

    setup do
      @cache_list = com_cache_lists(:one)
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/cache_lists')
      assert_response :success
    end

    test 'new ok' do
      get url_for(controller: 'com/panel/cache_lists', action: 'new')
      assert_response :success
    end

    test 'create ok' do
      assert_difference('Com::CacheList.count') do
        post(
          url_for(controller: 'com/panel/cache_lists', action: 'create'),
          params: { cache_list: { key: 'xx' } },
          as: :turbo_stream
        )
      end
      assert_response :success
    end

    test 'show ok' do
      get url_for(controller: 'com/panel/cache_lists', action: 'new', id: @cache_list.id)
      assert_response :success
    end

    test 'edit ok' do
      get url_for(controller: 'com/panel/cache_lists', action: 'edit', id: @cache_list.id)
      assert_response :success
    end

    test 'update ok' do
      patch(
        url_for(controller: 'com/panel/cache_lists', action: 'update', id: @cache_list.id),
        params: { cache_list: { key: 'xx' } },
        as: :turbo_stream
      )
      assert_response :success
    end

    test 'destroy ok' do
      assert_difference('Com::CacheList.count', -1) do
        delete url_for(controller: 'com/panel/cache_lists', action: 'destroy', id: @cache_list.id), as: :turbo_stream
      end

      assert_response :success
    end
  end
end
