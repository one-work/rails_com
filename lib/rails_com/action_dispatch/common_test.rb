module RailsCom::ActionDispatch
  module CommonTest

    def test_create_ok
      assert_difference -> { @task.class.count } do
        post(
          url_for(controller: 'print/tasks', action: 'create', printer_id: 'dddddd'),
          params: {
            task: {
              body: @task.body
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
