module ActionController
  class StandardError < ::StandardError
    attr_accessor :code
  end
end
