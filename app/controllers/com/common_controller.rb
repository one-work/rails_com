module Com
  class CommonController < BaseController
    if whether_filter :verify_authenticity_token
      skip_forgery_protection only: [:deploy, :cors_preflight_check]
    end

    def info
      q_params = {}
      q_params.merge! params.permit(:platform)

      @infos = Info.default_where(q_params)
    end

    def cancel
    end

    def cache_list
      render json: CacheList.all.as_json(only: [:path, :key], methods: [:etag])
    end

    def enum_list
      r = I18n.backend.translations[I18n.locale][:activerecord][:enum]

      render json: { locale: I18n.locale, values: r }
    end

    def state_return
      state = Com::State.find_by(id: params[:state])
      if state
        state.update user_id: Current.session&.user_id, destroyable: true
        render layout: 'raw', locals: { state: state, auth_token: Current.session&.id }
      else
        render 'visit'
      end
    end

    def qrcode
      options = qrcode_params.to_h.symbolize_keys
      buffer = QrcodeUtil.code_png(params[:url], **options)

      send_data buffer, filename: 'cert_file.png', disposition: 'inline', type: 'image/png'
    end

    def actions
      if params[:model].present? && params[:id].present?
        model = params[:model].safe_constantize.find params[:id]
        render 'actions', locals: { model: model }
      end
    end

    def test_raise
      raise 'error from test raise'
    end

    # commit message end with '@deploy'
    def deploy
      require 'deploy'
      digest = request.headers['X-Hub-Signature'].to_s
      digest.sub!('sha1=', '')
      payload = JSON.parse(params[:payload])

      if digest == Deploy.github_hmac(request.body.read) && payload.dig('head_commit', 'message').to_s.end_with?('@deploy')
        result = Deploy.exec_cmds Rails.env.to_s
      else
        result = ''
        logger.debug "\e[35m  Deploy failed  \e[0m"
      end

      render plain: result
    end

    def asset
      file = "#{params[:path]}.#{params[:format]}"
      real_path = Rails.root.join('app/views', "#{current_organ.code}/assets", file)

      expires_in 10.hours, public: true
      send_file real_path
    end

    def cors_preflight_check
      response.headers['Access-Control-Allow-Origin'] = request.origin
      response.headers['Access-Control-Allow-Methods'] = 'GET'
      response.headers['Access-Control-Allow-Headers'] = request.headers['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']
      response.headers['Access-Control-Max-Age'] = '1728000'
      response.headers['Access-Control-Allow-Credentials'] = true

      head :no_content
    end

    def geo
      @url = URI(params[:url])
      factory = RGeo::Geographic.spherical_factory(srid: 4326)
      session_point = factory.point(session[:longitude], session[:latitude])
      params_point = factory.point(params[:longitude], params[:latitude])
      distance = session_point.distance(params_point)
      logger.debug "\e[35m  Distance: #{distance}  \e[0m"

      if distance > 10
        session[:latitude] = params[:latitude]
        session[:longitude] = params[:longitude]

        resume_session unless Current.session
        if Current.session && Current.session.user
          Current.session.user.set_geo!(session[:longitude], session[:latitude])
        end
      else
        head :ok and return
      end
    end

    private
    def qrcode_params
      params.permit(
        :resize_gte_to,
        :resize_exactly_to,
        :fill,
        :color,
        :size,
        :border_modules,
        :module_px_size
      )
    end

  end
end
