# frozen_string_literal: true

module DockerRegistryApi
  extend CommonApi
  extend self
  BASE_URL = 'http://localhost:5555/v2/'

  def tags(res)
    get "#{res}/tags/list", origin: BASE_URL
  end

  def with_access_token(**)
    yield
  end

end