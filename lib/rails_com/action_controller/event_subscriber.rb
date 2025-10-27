module RailsCom::ActionController
  class EventSubscriber < ActiveSupport::StructuredEventSubscriber
    attach_to :action_controller

    def start_processing(event)
    end

    def process_action(event)
      request = event.payload[:request]

      emit_event(
        'controller.process_action',
        controller: event.payload[:controller],
        action: event.payload[:action],
        format: event.payload[:format],
        timestamp: Time.now.iso8601(6),
        uuid: request.request_id
      )
    end

  end
end
