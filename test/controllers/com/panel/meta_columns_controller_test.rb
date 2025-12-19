require 'test_helper'
module Com
  class Panel::MetaColumnsControllerTest < ActionDispatch::IntegrationTest

    setup do
      @meta_column = meta_columns(:one)
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/meta_columns')

      assert_response :success
    end

    test 'new ok' do
      get url_for(controller: 'com/panel/meta_columns')

      assert_response :success
    end

    test 'create ok' do
      assert_difference('Com::MetaColumn.count') do
        post(
          url_for(controller: 'com/panel/meta_columns', action: 'create'),
          params: { meta_column: { column_limit: @meta_column.column_limit, column_name: @meta_column.column_name, column_type: @meta_column.column_type, model_name: @meta_column.model_name, sql_type: @meta_column.sql_type } },
          as: :turbo_stream
        )
      end

      assert_response :success
    end

    test 'show ok' do
      get url_for(controller: 'com/panel/meta_columns', action: 'show', id: @meta_column.id)

      assert_response :success
    end

    test 'edit ok' do
      get url_for(controller: 'com/panel/meta_columns', action: 'edit', id: @meta_column.id)

      assert_response :success
    end

    test 'update ok' do
      patch(
        url_for(controller: 'com/panel/meta_columns', action: 'update', id: @meta_column.id),
        params: { meta_column: { column_limit: @meta_column.column_limit, column_name: @meta_column.column_name, column_type: @meta_column.column_type, model_name: @meta_column.model_name, sql_type: @meta_column.sql_type } },
        as: :turbo_stream
      )

      assert_response :success
    end

    test 'destroy ok' do
      assert_difference('Com::MetaColumn.count', -1) do
        delete url_for(controller: 'com/panel/meta_columns', action: 'destroy', id: @meta_column.id), as: :turbo_stream
      end

      assert_response :success
    end

  end
end
