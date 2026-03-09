# frozen_string_literal: true

module DockerRegistryApi
  extend CommonApi
  extend self

  def tags(res)
    get "#{res}/tags/list"
  end

  def purge(res)
    r = get "#{res}/tags/list"
    r.fetch('tags', []).each do |i|
      time, digest = tag(res, i)
      tag_delete(res, digest, debug: true)
    end
  end

  def tag(res, id)
    r = head "#{res}/manifests/#{id}"
    [r['date'].to_datetime, r['docker-content-digest']]
  end

  def tag_delete(res, digest, **options)
    delete "#{res}/manifests/#{digest}", **options
  end

  def base_url
    'http://localhost:5555/v2/'
  end

  def with_access_token(**)
    yield
  end

end