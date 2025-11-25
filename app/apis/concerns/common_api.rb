# frozen_string_literal: true
require 'httpx'
require 'http/form_data'

module CommonApi
  attr_reader :app, :client

  def initialize(app = nil)
    @app = app
    @client = HTTPX.with(
      ssl: {
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      },
      headers: {
        'Accept' => 'application/json'
      },
      timeout: {
        read_timeout: 120
      }
    )
  end

  def get(path, origin: @app.base_url, headers: {}, debug: nil, **params)
    request('GET', path, origin: origin, params: params, headers: headers, debug: debug)
  end

  def post(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request('POST', path, origin: origin, params: params, headers: headers, debug: debug, **payload)
  end

  def post_stream(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request('POST', path, origin: origin, params: params, headers: headers, debug: debug, stream: true, **payload)
  end

  def put(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request('PUT', path, origin: origin, params: params, headers: headers, debug: debug, **payload)
  end

  def delete(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request('DELETE', path, origin: origin, params: params, headers: headers, debug: debug, **payload)
  end

  def request(method, path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    with_options = { origin: origin }
    with_options.merge! debug: STDOUT, debug_level: 2 if debug

    with_access_token(params: params, headers: headers, payload: payload) do
      response = @client.with_headers(headers).with(with_options).request(method, path, params: params, json: payload)
      debug ? response : parse_response(response)
    end
  end

  def post_file(path, file, file_key: 'media', content_type: nil, params: {}, headers: {}, origin: nil, debug: nil, **options)
    with_options = { origin: origin }
    with_options.merge! debug: STDOUT, debug_level: 2 if debug

    with_access_token(params: params, headers: headers) do
      form_file = file.is_a?(HTTP::FormData::File) ? file : HTTP::FormData::File.new(file, content_type: content_type)
      response = @client.with_headers(headers).with(with_options).post(
        path,
        params: params,
        form: {
          file_key => form_file,
          **options
        }
      )

      debug ? response : parse_response(response)
    end
  end

  protected
  def with_access_token(tries: 2, params: {}, headers: {}, payload: {})
    @app.refresh_access_token unless @app.access_token_valid?
    params.merge!(access_token: @app.access_token)
    yield
  rescue AccessTokenExpiredError
    @app.refresh_access_token
    retry unless (tries -= 1).zero?
  end

  def parse_response(response)
    if response.respond_to?(:status) && response.status >= 200 && response.status < 300
      content_type = response.content_type.mime_type

      if content_type =~ /image|audio|video/
        data = Tempfile.new('tmp')
        data.binmode
        data.write(response.body.to_s)
        data.rewind
        data
      elsif content_type =~ /html|xml/
        Hash.from_xml(response.body.to_s)
      elsif content_type =~ /json/
        response.json
      else
        JSON.parse(response.body.to_s)
      end
    else
      raise "Request get fail, response status #{response}"
    end
  end

  def logger
    Rails.logger
  end

end