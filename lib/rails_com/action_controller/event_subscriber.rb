module RailsCom::ActionController
  class EventSubscriber < ActiveSupport::LogSubscriber
    attach_to :action_controller

    def start_processing(event)
      emit_event(
        'controller.request_started',
        controller: event.payload[:controller],
        action: event.payload[:action],
        format: event.payload[:format]
      )
    end

    def process_action(event)

    end


  end
end
