module RailsCom::ActionController
  class EventSubscriber < ActiveSupport::StructuredEventSubscriber
    attach_to :action_controller

    def start_processing(event)
    end

    def process_action(event)
      payload = event.payload
      request = payload[:request]
      raw_headers = payload.fetch(:headers, {})
      real_headers = Com::Err.request_headers(raw_headers)

      emit_event(
        'controller.process_action',
        path: request.fullpath,
        controller_name: payload[:controller],
        action_name: payload[:action],
        params: payload[:params].to_json,
        headers: real_headers.to_json,
        session: request.session.to_h.to_json,
        format: payload[:format].to_s,
        ip: request.remote_ip,
        session_id: request.session.id,
        created_at: Time.now.utc.iso8601(6),
        status: payload[:status],
        duration: event.duration.round,
        view_duration: payload[:view_runtime].round(1).to_s,
        db_duration: payload[:db_runtime].round(1).to_s,
        query_count: payload[:queries_count],
        query_cached_count: payload[:cached_queries_count],
        uuid: request.request_id
      )
    end

  end
end
