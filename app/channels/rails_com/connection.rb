module RailsCom::Connection
  extend ActiveSupport::Concern

  included do
    identified_by :verified_receiver, :session_id, :organ
  end

  def connect
    self.verified_receiver = find_verified_receiver
    self.session_id = cookies['session_id']
    self.organ = current_organ
  end

  protected
  def find_verified_receiver
    if cookies['session_id'] && defined?(Auth::Session)
      Rails.logger.silence do
        Auth::Session.find_by(id: cookies.signed['session_id'])
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

end
