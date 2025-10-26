module RailsCom::ActionController
  class EventSubscriber < ActiveSupport::StructuredEventSubscriber
    attach_to :action_controller

    def start_processing(event)
      Rails.logger.debug '---------------------------------------------'
      emit_event(
        'controller.request_started',
        controller: event.payload[:controller],
        action: event.payload[:action],
        format: event.payload[:format],
        timestamp: Time.now.iso8601(6)
      )
    end

    def process_action(event)
      Rails.logger.debug '---------------------------------------------'
    end

  end
end
