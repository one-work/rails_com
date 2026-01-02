module RailsCom::ActionDispatch
  module CommonTest

    def test_create_ok
      assert_difference('Task.count') do
        post(
          url_for(controller: 'print/tasks', action: 'create', printer_id: @task.mqtt_printer_id),
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
