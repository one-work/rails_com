require 'test_helper'
class Com::Admin::FiltersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @filter = filters(:one)
  end

  test 'index ok' do
    get url_for(controller: 'com/admin/filters')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'com/admin/filters')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Filter.count') do
      post(
        url_for(controller: 'com/admin/filters', action: 'create'),
        params: { filter: { name: @com_admin_filter.name } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'com/admin/filters', action: 'show', id: @filter.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'com/admin/filters', action: 'edit', id: @filter.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'com/admin/filters', action: 'update', id: @filter.id),
      params: { filter: { name: @com_admin_filter.name } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Filter.count', -1) do
      delete url_for(controller: 'com/admin/filters', action: 'destroy', id: @filter.id), as: :turbo_stream
    end

    assert_response :success
  end

end
