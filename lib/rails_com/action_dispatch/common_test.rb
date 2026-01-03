module RailsCom::ActionDispatch
  module CommonTest

    def self.prepended(klass)
      klass.setup do
        @model = access_fixture @action.model_path, @action.action_name
      end
    end

    def initialize(name, action)
      @action = action
      super(name)
    end

    def test_create_ok
      params = @loaded_fixtures[@action.model_path].fixtures['create'].fixture
      url_parts = @model.attributes.slice(*@action.required_parts)

      assert_difference -> { @model.class.count } do
        post(
          nil,
          url: { controller: @action.controller_path, action: @action.action_name, **url_parts },
          params: { @model.class.base_class.model_name.param_key => params },
          as: :turbo_stream
        )
      end

      assert_response :success
    end

  end
end

ActionDispatch::IntegrationTest.prepend RailsCom::ActionDispatch::CommonTest
