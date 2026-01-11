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
        @url_parts = @model.attributes.slice(*@action.required_parts)
        @params = @loaded_fixtures[@action.model_path].fixtures[key].fixture.except('id', 'created_at', 'updated_at', *@action.required_parts)
        @comments = @loaded_fixtures[@action.model_path].comments[key]
      end
    end

    def initialize(name, action)
      @action = action
      super(name)
    end

    def test_index_ok
      get nil, url: { controller: @action.controller_path, action: @action.action_name }, comments: @comments
      assert_response :success
    end

    def test_new_ok
      get nil, url: { controller: @action.controller_path, action: @action.action_name }, as: @action.request_as, comments: @comments
      assert_response :success
    end

    def test_create_ok
      assert_difference -> { @model.class.count } do
        post(
          nil,
          url: { controller: @action.controller_path, action: @action.action_name, **@url_parts },
          params: @params,
          as: @action.request_as,
          comments: @comments
        )
      end
      assert_response :success
    end

    def test_show_ok
      get nil, url: { controller: @action.controller_path, action: @action.action_name, id: @model.id }, as: @action.request_as, comments: @comments
      assert_response :success
    end

    def test_edit_ok
      get nil, url: { controller: @action.controller_path, action: @action.action_name, id: @model.id }, as: @action.request_as, comments: @comments
      assert_response :success
    end

    def test_update_ok
      patch(
        nil,
        url: { controller: @action.controller_path, action: @action.action_name, id: @model.id },
        params: { @model.class.base_class.model_name.param_key => @params },
        as: @action.request_as,
        comments: @comments
      )
      assert_response :success
    end

    def test_destroy_ok
      assert_difference -> { @model.class.count }, -1 do
        delete nil, url: { controller: @action.controller_path, action: @action.action_name, id: @model.id }, as: @action.request_as, comments: @comments
      end

      assert_response :success
    end

    def test_add_ok
      assert_difference -> { @model.class.count } do
        common_request
      end
      assert_response :success
    end

    private
    def common_request
      integration_session.process(
        @action.verb.downcase,
        nil,
        url: { controller: @action.controller_path, action: @action.action_name, **@url_parts },
        params: @params,
        as: @action.request_as,
        comments: @comments
      )
      copy_session_variables!
    end

  end
end

ActionDispatch::IntegrationTest.prepend RailsCom::ActionDispatch::CommonTest
