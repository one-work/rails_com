module RailsCom::ActionDispatch
  module CommonTest

    def self.prepended(klass)
      klass.setup do
        keys = @loaded_fixtures[@action.model_path].fixtures.keys
        if keys.include?(@action.action_name)
          key = @action.action_name
        else
          key = 'default'
        end
        @model = access_fixture @action.model_path, key
        @params = @loaded_fixtures[@action.model_path].fixtures[key].fixture
      end
    end

    def initialize(name, action)
      @action = action
      super(name)
    end

    def test_index_ok
      get nil, url: { controller: @action.controller_path, action: @action.action_name }
      assert_response :success
    end

    def test_new_ok
      get nil, url: { controller: @action.controller_path, action: @action.action_name }, as: :turbo_stream
      assert_response :success
    end

    def test_create_ok
      url_parts = @model.attributes.slice(*@action.required_parts)

      assert_difference -> { @model.class.count } do
        post(
          nil,
          url: { controller: @action.controller_path, action: @action.action_name, **url_parts },
          params: { @model.class.base_class.model_name.param_key => @params },
          as: :turbo_stream
        )
      end
      assert_response :success
    end

    def test_show_ok
      get nil, url: { controller: @action.controller_path, action: @action.action_name, id: @model.id }, as: :turbo_stream
      assert_response :success
    end

    def test_edit_ok
      get nil, url: { controller: @action.controller_path, action: @action.action_name, id: @model.id }, as: :turbo_stream
      assert_response :success
    end

    def test_update_ok
      patch(
        nil,
        url: { controller: @action.controller_path, action: @action.action_name, id: @model.id },
        params: { @model.class.base_class.model_name.param_key => @params },
        as: :turbo_stream
      )
      assert_response :success
    end

    def test_destroy_ok
      assert_difference -> { @model.class.count }, -1 do
        delete nil, url: { controller: @action.controller_path, action: @action.action_name, id: @model.id }, as: :turbo_stream
      end

      assert_response :success
    end

  end
end

ActionDispatch::IntegrationTest.prepend RailsCom::ActionDispatch::CommonTest
