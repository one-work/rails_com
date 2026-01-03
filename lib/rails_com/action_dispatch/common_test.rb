module RailsCom::ActionDispatch
  module CommonTest

    def self.prepended(klass)
      klass.setup do

      end
    end

    def initialize(name, action)
      @action = action
      super(name)
    end

    def test_create_ok
      url_parts = @model.attributes.slice(*@action.required_parts)

      assert_difference -> { @model.class.count } do
        post(
          nil,
          url: { controller: @action.controller_path, action: @action.action_name, **url_parts },
          params: {
            task: {
              body: @model.body
            }
          },
          as: :turbo_stream
        )
      end

      assert_response :success
    end

  end
end

ActionDispatch::IntegrationTest.prepend RailsCom::ActionDispatch::CommonTest
