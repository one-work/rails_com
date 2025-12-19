require 'test_helper'
module Com
  class Panel::MetaModelsControllerTest < ActionDispatch::IntegrationTest

    setup do
      @meta_model = meta_models(:one)
    end

    test 'index ok' do
      get url_for(controller: 'com/panel/meta_models')

      assert_response :success
    end

    test 'new ok' do
      get url_for(controller: 'com/panel/meta_models')

      assert_response :success
    end

    test 'create ok' do
      assert_difference('Com::MetaModel.count') do
        post(
          url_for(controller: 'com/panel/meta_models', action: 'create'),
          params: { meta_model: { description: @meta_model.description, model_name: @meta_model.model_name, name: @meta_model.name } },
          as: :turbo_stream
        )
      end

      assert_response :success
    end

    test 'show ok' do
      get url_for(controller: 'com/panel/meta_models', action: 'show', id: @meta_model.id)

      assert_response :success
    end

    test 'edit ok' do
      get url_for(controller: 'com/panel/meta_models', action: 'edit', id: @meta_model.id)

      assert_response :success
    end

    test 'update ok' do
      patch(
        url_for(controller: 'com/panel/meta_models', action: 'update', id: @meta_model.id),
        params: { meta_model: { description: @meta_model.description, model_name: @meta_model.model_name, name: @meta_model.name } },
        as: :turbo_stream
      )

      assert_response :success
    end

    test 'destroy ok' do
      assert_difference('Com::MetaModel.count', -1) do
        delete url_for(controller: 'com/panel/meta_models', action: 'destroy', id: @meta_model.id), as: :turbo_stream
      end

      assert_response :success
    end

  end
end
