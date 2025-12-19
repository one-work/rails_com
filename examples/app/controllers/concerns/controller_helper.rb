module RailsCom::ControllerHelper

  def inc_ip_count
    Rails.cache.write "access/#{request.remote_ip}", ip_count + 1, expires_in: 60.seconds
  end

  def clear_ip_count
    Rails.cache.write "access/#{request.remote_ip}", 0, expires_in: 60.seconds
  end

  def ip_count
    Rails.cache.read("access/#{request.remote_ip}").to_i
  end

  def require_recaptcha
    inc_ip_count
    if ip_count >= 100
      session[:back_to] = request.fullpath
      redirect_to '/the_guards'
    end
  end

end