module RailsCom::Connection
  extend ActiveSupport::Concern

  included do
    identified_by :verified_receiver, :session_id, :organ
  end

  def connect
    self.verified_receiver = find_verified_receiver
    self.session_id = session['session_id'] if session
    self.organ = current_organ
  end

  protected
  def find_verified_receiver
    return unless session
    if session['auth_token'] && defined?(Auth::AuthorizedToken)
      Rails.logger.silence do
        Auth::AuthorizedToken.find_by(id: session['auth_token'])
      end
    end
  rescue
    logger.error 'An unauthorized connection attempt was rejected'
    nil
  end

  def current_organ
    organ_domain = Org::OrganDomain.annotate('get organ domain in org application').find_by(host: request.host)
    if organ_domain
      organ_domain.organ
    end
  end

  def session
    session_key = Rails.configuration.session_options[:key]
    cookies.encrypted[session_key]
  end

end
