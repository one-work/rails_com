module Com
  class LogController < BaseController
    skip_before_action :verify_authenticity_token if defined? verify_authenticity_token
    rate_limit to: 10, within: 1.minute, with: :redirect_for_too_many, only: [:not_found]

    def not_found
      logger.debug "\e[35m  format: #{request.format}, path: #{request.path_parameters}  \e[0m"
      params.permit!
      RailsCom.config.not_found_logger.info "#{params[:path]}.#{params[:format]}"

      head :not_found
    end

    def csp
      data = JSON.parse(request.body.read)
      p = data.fetch('csp-report', {})
      p.transform_keys!(&:underscore)

      LogCsp.create(p)

      head :no_content
    end

    def index
      path = Rails.root + RailsCom.config.not_found_logger.instance_variable_get(:@logdev).filename
      result = `tail -n200 #{path}`

      render plain: result
    end

  end
end
