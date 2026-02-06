# frozen_string_literal: true
require 'httpx'
require 'http/form_data'

module CommonApi
  class AccessTokenExpiredError < StandardError; end
  attr_accessor :app, :client

  def initialize(app = nil)
    @app = app
    set_client
  end

  def set_client
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

  def get_xml(path = '/', **params)
    r = @client.plugin(:xml).get(path, origin: @app.base_url, params: params)
    parse_response(r)
  end

  def post(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request('POST', path, payload, origin: origin, params: params, headers: headers, debug: debug)
  end

  def post_form(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request_form('POST', path, payload, origin: origin, params: params, headers: headers, debug: debug)
  end

  def post_array(path, payload, origin: @app.base_url, params: {}, headers: {}, debug: nil)
    request('POST', path, payload, origin: origin, params: params, headers: headers, debug: debug)
  end

  def post_stream(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request('POST', path, payload, origin: origin, params: params, headers: headers, debug: debug, stream: true)
  end

  def put(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request('PUT', path, payload, origin: origin, params: params, headers: headers, debug: debug)
  end

  def delete(path, origin: @app.base_url, params: {}, headers: {}, debug: nil, **payload)
    request('DELETE', path, payload, origin: origin, params: params, headers: headers, debug: debug)
  end

  def request(method, path, payload = nil, origin: @app.base_url, params: {}, headers: {}, debug: nil)
    with_options = { origin: origin }
    with_options.merge! debug: STDOUT, debug_level: 2 if debug

    with_access_token(params: params, headers: headers, payload: payload) do
      response = @client.with_headers(headers).with(with_options).request(method, path, params: params, json: payload)
      debug ? response : parse_response(response)
    end
  end

  def request_form(method, path, payload, origin:, params: {}, headers: {}, debug: nil)
    with_options = { origin: origin }
    with_options.merge! debug: STDOUT, debug_level: 2 if debug

    with_access_token(params: params, headers: headers, payload: payload) do
      response = @client.with_headers(headers).with(with_options).request(method, path, params: params, form: payload)
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
    headers.merge! 'Authorization' => "Bearer #{@app.access_token}"
    yield
  rescue AccessTokenExpiredError
    @app.refresh_access_token
    retry unless (tries -= 1).zero?
  end

  def parse_response(response)
    if response.respond_to?(:status) && response.status >= 200 && response.status < 300
      content_type = response.content_type.mime_type

      body = if content_type =~ /image|audio|video/
        data = Tempfile.new('tmp')
        data.binmode
        data.write(response.body.to_s)
        data.rewind

        return data
      elsif content_type =~ /html|xml/
        Hash.from_xml(response.body.to_s)
      elsif content_type =~ /json/
        response.json
      else
        JSON.parse(response.body.to_s)
      end

      extra(body)
    else
      raise AccessTokenExpiredError, "Request get fail, response status #{response}"
    end
  end

  def extra(body)
    body
  end

  def logger
    Rails.logger
  end

end