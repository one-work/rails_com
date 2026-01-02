module RailsCom::ActionDispatch
  module Session

    def process(method, path, params: nil, headers: nil, env: nil, xhr: false, as: nil)
      super
    end

  end
end

ActionDispatch::Integration::Session.prepend RailsCom::ActionDispatch::Session
