module RailsCom::ActionDispatch
  module Session

    def process(method, path = nil, url: {}, params: nil, headers: nil, env: nil, xhr: false, as: nil)
      if path.nil?
        path = url_for(url)
      end
      binding.b
      super(method, path, params: params, headers: headers, env: env, xhr: xhr, as: as)
    end

  end
end

ActionDispatch::Integration::Session.prepend RailsCom::ActionDispatch::Session
