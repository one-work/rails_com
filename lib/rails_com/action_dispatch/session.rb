module RailsCom::ActionDispatch
  module Session

    def process(method, path = nil, url: {}, params: nil, headers: nil, env: nil, xhr: false, as: nil, **options)
      if path.nil?
        path = url_for(url)
      end

      r = super(method, path, params: params, headers: headers, env: env, xhr: xhr, as: as)

      doc_subject = Doc::Subject.find_by(controller_path: url[:controller], action_name: url[:action], response_status: r)
      if doc_subject
        type = Mime::Type.lookup(@response.media_type).ref
        doc_subject.request_params = params
        doc_subject.request_comments = options[:comments]
        doc_subject.request_type = as
        doc_subject.response_body = @response.parsed_body
        doc_subject.response_type = type

        doc_subject.class.transaction(requires_new: true) do |t|
          doc_subject.save!
          doc_subject.class.connection.commit_transaction
        end
      end
    end

  end
end

ActionDispatch::Integration::Session.prepend RailsCom::ActionDispatch::Session
