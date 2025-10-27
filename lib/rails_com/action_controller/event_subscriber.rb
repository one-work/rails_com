module RailsCom::ActionController
  class EventSubscriber < ActiveSupport::StructuredEventSubscriber
    attach_to :action_controller

    def start_processing(event)
    end

    def process_action(event)
      payload = event.payload
      request = payload[:request]

      binding.b
      emit_event(
        'controller.process_action',
        controller: payload[:controller],
        action: payload[:action],
        params: payload[:params].to_json,
        format: payload[:format].to_s,
        timestamp: Time.now.iso8601(6),
        uuid: request.request_id
      )
    end

  end
end
